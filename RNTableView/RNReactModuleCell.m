//
//  RNReactModuleCell.m
//  RNTableView
//
//  Created by Anna Berman on 2/6/16.
//  Copyright © 2016 Pavlo Aksonov. All rights reserved.
//

#import <RCTRootView.h>
#import <RCTRootViewDelegate.h>
#import "RNReactModuleCell.h"
#import "RNTableView.h"

@interface RNReactModuleCell()<RCTRootViewDelegate>
@end

@implementation RNReactModuleCell {
    RCTRootView *_rootView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bridge:(RCTBridge*) bridge data:(NSDictionary*)data indexPath:(NSIndexPath*)indexPath reactModule:(NSString*)reactModule tableViewTag:(NSNumber*)reactTag
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setComponentHeight:UITableViewAutomaticDimension];
        [self setUpAndConfigure:data bridge:bridge indexPath:indexPath reactModule:reactModule tableViewTag:reactTag];
    }
    return self;
}

-(NSDictionary*) toProps:(NSDictionary *)data indexPath:(NSIndexPath*)indexPath reactTag:(NSNumber*)reactTag {
    return @{@"data":data, @"section":[[NSNumber alloc] initWithLong:indexPath.section], @"row":[[NSNumber alloc] initWithLong:indexPath.row], @"tableViewReactTag":reactTag};
}

-(void)setUpAndConfigure:(NSDictionary*)data bridge:(RCTBridge*)bridge indexPath:(NSIndexPath*)indexPath reactModule:(NSString*)reactModule tableViewTag:(NSNumber*)reactTag {
    [self setIndexPath:indexPath];
    NSDictionary *props = [self toProps:data indexPath:indexPath reactTag:reactTag];
    if (_rootView == nil) {
        //Create the mini react app that will populate our cell. This will be called from cellForRowAtIndexPath
        _rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:reactModule initialProperties:props];
        _rootView.delegate = self;
        [self setComponentHeight:_rootView.intrinsicSize.height];
        [_rootView setSizeFlexibility:RCTRootViewSizeFlexibilityHeight];
        [self.contentView addSubview:_rootView];
        self.contentView.frame = CGRectMake(
            self.contentView.frame.origin.x,
            self.contentView.frame.origin.y,
            self.contentView.frame.size.width,
            _rootView.intrinsicSize.height);
        _rootView.frame = self.contentView.frame;
        _rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        //Ask react to re-render us with new data
        [_rootView setAppProperties:props];
    }
    //The application will be unmounted in javascript when the cell/rootview is destroyed
}

-(CGFloat)getHeightFromRootView {
    CGFloat height = [self componentHeight];
    if (height <= 0) {
        return 100;
    } else {
        return height;
    }
}

-(void)prepareForReuse {
    [super prepareForReuse];
    //TODO prevent stale data flickering
}

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    CGRect newFrame = rootView.frame;
    newFrame.size = rootView.intrinsicSize;
    self.contentView.frame = newFrame;
//    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
//                                        self.contentView.frame.origin.y,
//                                        self.contentView.frame.size.width,
//                                        newFrame.size.height);
   [self setComponentHeight:newFrame.size.height];

    [[self tableView] reloadRowsAtIndexPaths:@[[self indexPath]] withRowAnimation:UITableViewRowAnimationFade];
}


@end
