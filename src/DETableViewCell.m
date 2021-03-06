//
//  DETableViewCell.m
//
//  Created by Jeremy Flores on 12/20/13.
//  Copyright (c) 2013 Dream Engine Interactive, Inc. All rights reserved.
//

#import "DETableViewCell.h"
#import "OSCache.h"

@implementation UITableView (DETableViewCell)

-(void)registerDETableViewCellClass:(Class)cellClass {
    if ([cellClass isSubclassOfClass:[DETableViewCell class]]) {
        [self registerNib: [cellClass cellNib]
   forCellReuseIdentifier: [cellClass reuseIdentifier]];
    }
}

-(void)unregisterDETableViewCellClass:(Class)cellClass {
    if ([cellClass isSubclassOfClass:[DETableViewCell class]]) {
        [self registerNib: nil
   forCellReuseIdentifier: [cellClass reuseIdentifier]];
    }
}

@end


@implementation DETableViewCell

static OSCache *CellNibCache = nil;


#pragma mark - Cell Nib Cache

+(OSCache *)CellNibCache {
    @synchronized(self) {
        if (!CellNibCache) {
            CellNibCache = [OSCache new];
        }
    }

    return CellNibCache;
}


#pragma mark - UINib Access

+(UINib *)cellNib {
    UINib *cellNib = nil;

    @synchronized(self) {
        OSCache *cellNibCache = self.class.CellNibCache;

        cellNib = [cellNibCache objectForKey:self];

        if (!cellNib) {
            NSURL *url = [[NSBundle mainBundle] URLForResource: NSStringFromClass(self)
                                                 withExtension: @"nib"];
            BOOL doesNibExist = [url checkResourceIsReachableAndReturnError:nil];

            if (doesNibExist) {
                cellNib = [UINib nibWithNibName: NSStringFromClass(self)
                                         bundle: nil];
                [cellNibCache setObject: cellNib
                                 forKey: self];
            }
        }
    };

    return cellNib;
}


#pragma mark - Cache Reduction

+(void)removeCellNibFromCache {
    @synchronized(self) {
        OSCache *cellNibCache = self.CellNibCache;
        [cellNibCache removeObjectForKey:self];
    };
}

+(void)removeAllCellNibsFromCache {
    @synchronized(self) {
        OSCache *cellNibCache = self.CellNibCache;
        [cellNibCache removeAllObjects];
    }
}


#pragma mark - Factory/Construction Method

+(instancetype)cell {
    NSURL *url = [[NSBundle mainBundle] URLForResource: NSStringFromClass(self)
                                         withExtension: @"nib"];
    BOOL doesNibExist = [url checkResourceIsReachableAndReturnError:nil];

    DETableViewCell *cell;
    if (doesNibExist) {
        cell = [self.cellNib instantiateWithOwner: nil
                                          options: nil][0];
    }
    else {
        cell = [[self alloc] initWithStyle: UITableViewCellStyleDefault
                           reuseIdentifier: self.reuseIdentifier];
    }

    return cell;
}


#pragma mark - Reuse Identifier

+(NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

-(NSString *)reuseIdentifier {
    return [self.class reuseIdentifier];
}

@end
