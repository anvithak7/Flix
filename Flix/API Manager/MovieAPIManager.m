//
//  MovieAPIManager.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/30/21.
//

#import "MovieAPIManager.h"
#import "Movie.h"
#import "UIImageView+AFNetworking.h"

@interface MovieAPIManager()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation MovieAPIManager

- (id)init {
    self = [super init];

    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    return self;
}

- (void)fetchNowPlaying:(void(^)(NSMutableArray *movies, NSError *error))completion {
    // The loading indicator starts up when something is loading/fetching from network.
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    // In the above, whichever URL you want to get data from.
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    // The request ignores cache data because we always want to see it reload.
    // In real life, we might want to cache things that are relevant to load it quicker for the user.
    // NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    // In the below, ^() is the syntax for a block.
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The lines below happen once the network call is finished.
        // Network call has to be done in the background, or in the foreground thread would feel like user was frozen.
           if (error != nil) {
               // The network request has completed, but failed.
               // Invoke the completion block with an error.
               // Think of invoking a block like calling a function with parameters
               NSLog(@"%@", [error localizedDescription]); // If there's an error, print it out.
               completion(nil, error);
           }
           else { // The API gave us something back! In the form of a dictionary!
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // %@ means specifying an object.
               NSLog(@"%@", dataDictionary);
               NSArray *dictionaries = dataDictionary[@"results"];
               NSMutableArray *movies = [Movie moviesWithDictionaries:dictionaries];
               completion(movies, nil);
               // The network request has completed, and succeeded.
               // Invoke the completion block with the movies array.
               // Think of invoking a block like calling a function with parameters
               // Get the array of movies
               // Store the movies in a property to use elsewhere
               // Reload your table view data
           }
       }];
    [task resume];
}

- (void)fetchPopularMovies:(void(^)(NSMutableArray *movies, NSError *error))completion {
    // The loading indicator starts up when something is loading/fetching from network.
    //[self.loadingIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/popular?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    // In the above, whichever URL you want to get data from.
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    // The request ignores cache data because we always want to see it reload.
    // In real life, we might want to cache things that are relevant to load it quicker for the user.
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    // In the below, ^() is the syntax for a block.
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The lines below happen once the network call is finished.
        // Network call has to be done in the background, or in the foreground thread would feel like user was frozen.
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]); // If there's an error, print it out.
               // The network request has completed, but failed.
               // Invoke the completion block with an error.
               // Think of invoking a block like calling a function with parameters
               completion(nil, error);
           }
           else { // The API gave us something back! In the form of a dictionary!
               NSLog(@"Something happened");
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // %@ means specifying an object.
               NSLog(@"%@", dataDictionary);
               NSArray *dictionaries = dataDictionary[@"results"];
               NSMutableArray *movies = [Movie moviesWithDictionaries:dictionaries];
               // The network request has completed, and succeeded.
               // Invoke the completion block with the movies array.
               // Think of invoking a block like calling a function with parameters
               completion(movies, nil);
           }
       }];
    [task resume];
}
    
    
@end
