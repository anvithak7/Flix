//
//  MovieAPIManager.h
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/30/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieAPIManager : NSObject

- (void)fetchNowPlaying:(void(^)(NSMutableArray *movies, NSError *error))completion;
- (void)fetchPopularMovies:(void(^)(NSMutableArray *movies, NSError *error))completion;


@end

NS_ASSUME_NONNULL_END
