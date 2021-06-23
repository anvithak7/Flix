//
//  MoviesViewController.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/23/21.
//

#import "MoviesViewController.h"

@interface MoviesViewController ()

// nonatomic and strong indicate how the compiler should generate the getter and setter methods.
// No garbage collector, so we have to use reference counting.
// Incrememnt reference counter of movies so it doesn't go away (with strong, increments retain count.
// Most things are nonatomic (very rarely otherwise).
@property (nonatomic, strong) NSArray *movies; // Creates a private instance variable with a getter and setter method.

@end

@implementation MoviesViewController

// Lifecycle methods are called automatically by the system.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    // In the above, whichever URL you want to get data from.
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    // The request ignores cache data because we always want to see it reload.
    // In real life, we might want to cache things that are relevant to load it quicker for the user.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    // In the below, ^() is the syntax for a block.
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The lines below happen once the network call is finished.
        // Network call has to be done in the background, or in the foreground thread would feel like user was frozen.
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]); //If there's an error, print it out.
           }
           else { // The API gave us something back! In the form of a dictionary!
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // %@ means specifying an object.
               NSLog(@"%@", dataDictionary);
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
       }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
