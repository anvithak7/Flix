//
//  Movie.h
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/30/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Movie : NSObject

@property (nonatomic, strong) NSString *movieID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *synopsis;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *ratings;
@property (nonatomic, strong) NSURL *lowResPosterURL;
@property (nonatomic, strong) NSURL *highResPosterURL;
@property (nonatomic, strong) NSURL *lowResBackdropURL;
@property (nonatomic, strong) NSURL *highResBackdropURL;


- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)moviesWithDictionaries:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
