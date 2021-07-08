//
//  CXQuadTree.h
//  Pods
//
//  Created by wshaolin on 2018/9/19.
//

#import <Foundation/Foundation.h>

typedef struct CXQuadTreeNodeData {
    double x;
    double y;
    void *data;
} CXQuadTreeNodeData;

CXQuadTreeNodeData CXQuadTreeNodeDataMake(double x, double y, void *data);

typedef struct CXBoundingBox {
    double x0;
    double y0;
    double xm;
    double ym;
} CXBoundingBox;

CXBoundingBox CXBoundingBoxMake(double x0, double y0, double xm, double ym);

typedef struct CXQuadTreeNode {
    struct CXQuadTreeNode *northEast;
    struct CXQuadTreeNode *northWest;
    struct CXQuadTreeNode *southEast;
    struct CXQuadTreeNode *southWest;
    
    CXBoundingBox boundingBox;
    NSUInteger capacity;
    CXQuadTreeNodeData *points;
    NSUInteger pointsCount;
} CXQuadTreeNode;

CXQuadTreeNode *CXQuadTreeNodeMake(CXBoundingBox boundingBox, NSUInteger capacity);

/*!
 * 建立四叉树
 * @param data        用于建树的节点数据指针
 * @param count       节点数据的个数
 * @param boundingBox 四叉树覆盖的范围
 * @param capacity    单节点能容纳的节点数据个数
 * @return 四叉树的根节点
 */
CXQuadTreeNode *CXQuadTreeBuildWithData(CXQuadTreeNodeData *data,
                                        NSUInteger count,
                                        CXBoundingBox boundingBox,
                                        NSUInteger capacity);

/*!
 * 在四叉树中插入节点数据
 * @param node 插入的节点位置
 * @param data 需要插入的节点数据
 * @return 成功插入返回YES，否则NO
 */
bool CXQuadTreeNodeInsertData(CXQuadTreeNode *node, CXQuadTreeNodeData data);

/*!
 * 拆分节点
 * @param node 输入需拆分的节点
 */
void CXQuadTreeNodeSubdivide(CXQuadTreeNode *node);

/*!
 * 判断节点数据是否在box范围内
 * @param boundingBox  范围
 * @param data 节点数据
 * @return 若data在box内，返回YES，否则NO
 */
bool CXBoundingBoxContainsData(CXBoundingBox boundingBox, CXQuadTreeNodeData data);

/*!
 * 判断两box是否相交
 * @return 若相交，返回YES，否则NO
 */
bool CXBoundingBoxIntersectsBoundingBox(CXBoundingBox boundingBox1, CXBoundingBox boundingBox2);

typedef void(^CXQuadTreeNodeDataCallback)(CXQuadTreeNodeData data);

void CXQuadTreeGatherDataInRange(CXQuadTreeNode *node,
                                 CXBoundingBox range,
                                 CXQuadTreeNodeDataCallback callback);

/*!
 * 清空四叉树
 * @param node 四叉数根节点
 */
void CXFreeQuadTreeNode(CXQuadTreeNode *node);
