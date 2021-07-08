//
//  CXQuadTree.m
//  Pods
//
//  Created by wshaolin on 2018/9/19.
//

#import "CXQuadTree.h"

CXQuadTreeNodeData CXQuadTreeNodeDataMake(double x, double y, void *data) {
    CXQuadTreeNodeData nodeData;
    nodeData.x = x;
    nodeData.y = y;
    nodeData.data = data;
    return nodeData;
}

CXBoundingBox CXBoundingBoxMake(double x0, double y0, double xm, double ym) {
    CXBoundingBox boundingBox;
    boundingBox.x0 = x0;
    boundingBox.y0 = y0;
    boundingBox.xm = xm;
    boundingBox.ym = ym;
    return boundingBox;
}

CXQuadTreeNode *CXQuadTreeNodeMake(CXBoundingBox boundingBox, NSUInteger capacity){
    CXQuadTreeNode *node = malloc(sizeof(CXQuadTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;
    
    node->boundingBox = boundingBox;
    node->capacity = capacity;
    node->pointsCount = 0;
    node->points = malloc(sizeof(CXQuadTreeNodeData) * capacity);
    
    return node;
}

bool CXBoundingBoxContainsData(CXBoundingBox boundingBox, CXQuadTreeNodeData data) {
    return (boundingBox.x0 <= data.x &&
            data.x <= boundingBox.xm &&
            boundingBox.y0 <= data.y &&
            data.y <= boundingBox.ym);
}

bool CXBoundingBoxIntersectsBoundingBox(CXBoundingBox boundingBox1, CXBoundingBox boundingBox2) {
    return (boundingBox1.x0 <= boundingBox2.xm &&
            boundingBox1.xm >= boundingBox2.x0 &&
            boundingBox1.y0 <= boundingBox2.ym &&
            boundingBox1.ym >= boundingBox2.y0);
}

void CXQuadTreeNodeSubdivide(CXQuadTreeNode *node) {
    CXBoundingBox box = node->boundingBox;
    
    double xMid = (box.xm + box.x0) * 0.5;
    double yMid = (box.ym + box.y0) * 0.5;
    
    CXBoundingBox northWest = CXBoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = CXQuadTreeNodeMake(northWest, node->capacity);
    
    CXBoundingBox northEast = CXBoundingBoxMake(xMid, box.y0, box.xm, yMid);
    node->northEast = CXQuadTreeNodeMake(northEast, node->capacity);
    
    CXBoundingBox southWest = CXBoundingBoxMake(box.x0, yMid, xMid, box.ym);
    node->southWest = CXQuadTreeNodeMake(southWest, node->capacity);
    
    CXBoundingBox southEast = CXBoundingBoxMake(xMid, yMid, box.xm, box.ym);
    node->southEast = CXQuadTreeNodeMake(southEast, node->capacity);
}

bool CXQuadTreeNodeInsertData(CXQuadTreeNode *node, CXQuadTreeNodeData data) {
    if(!CXBoundingBoxContainsData(node->boundingBox, data)){
        return false;
    }
    
    if(node->pointsCount < node->capacity){
        node->points[node->pointsCount ++] = data;
        return true;
    }
    
    // 若节点容量已满，且该节点为叶子节点，则向下扩展
    if(node->northWest == NULL){
        CXQuadTreeNodeSubdivide(node);
    }
    
    if(CXQuadTreeNodeInsertData(node->northWest, data)) return true;
    if(CXQuadTreeNodeInsertData(node->northEast, data)) return true;
    if(CXQuadTreeNodeInsertData(node->southWest, data)) return true;
    if(CXQuadTreeNodeInsertData(node->southEast, data)) return true;
    
    return false;
}

CXQuadTreeNode *CXQuadTreeBuildWithData(CXQuadTreeNodeData *data,
                                        NSUInteger count,
                                        CXBoundingBox boundingBox,
                                        NSUInteger capacity) {
    CXQuadTreeNode *node = CXQuadTreeNodeMake(boundingBox, capacity);
    for(NSUInteger index = 0; index < count; index ++){
        CXQuadTreeNodeInsertData(node, data[index]);
    }
    
    return node;
}

void CXQuadTreeGatherDataInRange(CXQuadTreeNode *node,
                                 CXBoundingBox range,
                                 CXQuadTreeNodeDataCallback callback) {
    // 若节点的覆盖范围与range不相交，则返回
    if(!CXBoundingBoxIntersectsBoundingBox(node->boundingBox, range)){
        return;
    }
    
    for(NSUInteger index = 0; index < node->pointsCount; index ++){
        // 若节点数据在range内，则调用block记录
        if(CXBoundingBoxContainsData(range, node->points[index])){
            callback(node->points[index]);
        }
    }
    
    // 若已是叶子节点，返回
    if(node->northWest == NULL){
        return;
    }
    
    // 不是叶子节点，继续向下查找
    CXQuadTreeGatherDataInRange(node->northWest, range, callback);
    CXQuadTreeGatherDataInRange(node->northEast, range, callback);
    CXQuadTreeGatherDataInRange(node->southWest, range, callback);
    CXQuadTreeGatherDataInRange(node->southEast, range, callback);
}

void CXFreeQuadTreeNode(CXQuadTreeNode *node) {
    if(node == NULL){
        return;
    }
    
    CXFreeQuadTreeNode(node->northWest);
    CXFreeQuadTreeNode(node->northEast);
    CXFreeQuadTreeNode(node->southWest);
    CXFreeQuadTreeNode(node->southEast);
    
    for(NSUInteger index = 0; index < node->pointsCount; index ++){
        CFRelease(node->points[index].data);
    }
    
    free(node->points);
    free(node);
}
