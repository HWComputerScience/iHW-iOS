//
//  IHWPeriodsChooserLayout.m
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWPeriodsChooserLayout.h"

@implementation IHWPeriodsChooserLayout

- (id)initWithNumDays:(int)numDays
{
    self = [super init];
    if (self) {
        self.numDays = numDays;
        self.marginSize = CGSizeMake(5, 5);
        self.cellSize = CGSizeZero;
        
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(280, 160);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *result = [NSMutableArray array];
    int numRows = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    int numCols = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    for (int i=0; i<numRows*numCols; i++) {
        [result addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i%numCols inSection:i/numCols]]];
    }
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CGSizeEqualToSize(self.cellSize, CGSizeZero)) {
        int numRows = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
        int numCols = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
        int usableSpaceX = [self collectionViewContentSize].width-self.marginSize.width*(numCols-2);
        int usableSpaceY = [self collectionViewContentSize].height-self.marginSize.height*(numRows-2);
        self.cellSize = CGSizeMake(usableSpaceX/numCols, usableSpaceY/numRows);
    }
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    int x = (self.cellSize.width+self.marginSize.width)*indexPath.row;
    int y = (self.cellSize.height+self.marginSize.height)*indexPath.section;
    attrs.frame = CGRectMake(x, y, self.cellSize.width, self.cellSize.height);
    attrs.alpha = 1;
    attrs.hidden = NO;
    return attrs;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

@end
