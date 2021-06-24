//
//  MoviesViewController.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/23/21.
//

#import "MoviesViewController.h"
#import "DetailsViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
// The above says that this class implements the two protocols there and their required methods.
// DataSource - how to show table view contents
// Delegate - how to respond to events (doesn't have required methods.

// nonatomic and strong indicate how the compiler should generate the getter and setter methods.
// No garbage collector, so we have to use reference counting.
// Incrememnt reference counter of movies so it doesn't go away (with strong, increments retain count).
// Most things are nonatomic (very rarely otherwise).
@property (nonatomic, strong) NSArray *movies; // Creates a private instance variable with a getter and setter method.
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

// Lifecycle methods are called automatically by the system.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self ; // The view controller is the data source and delegate!
    self.tableView.delegate = self;
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // addSubview allows you to nest views. insertSubview layers at whatever index.
}

- (void)fetchMovies {
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
               NSLog(@"%@", [error localizedDescription]); // If there's an error, print it out.
           }
           else { // The API gave us something back! In the form of a dictionary!
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // %@ means specifying an object.
               NSLog(@"%@", dataDictionary);
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               [self.tableView reloadData];
               // Get the array of movies
               // Store the movies in a property to use elsewhere
               // Reload your table view data
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}
// Called a few times on startup, and then never again.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count; // Number of rows/cells I have.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This creates cells as they need to be shown on the table view (some are made when user opens app, and then once they scroll, more are made afterwards (just in time)).
    // To save memory, old cells that disappear are "gone" and then are recreated as necessary. "Infinite number of rows"
    // With dequeue... they are put into a "resuable bag" and we have to reconfigure used cells.
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    // Separate note: UITableViewCell *cell = [[UITableViewCell alloc] init]; means allocate space for the TableViewCell and then initialize it (no default init).
    // Below, we're setting all the values in each cell by taking the appropriate value from the dictionary for each movie.
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    NSString *baseURLString = @"https:image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil; // Clear out the previous one before downloading the new one.
    [cell.posterView setImageWithURL:posterURL];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { // sender = generic for object that fired the event, and id is the tableview cell!
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie; // Passing over movie to next view controller.
    NSLog(@"Tapping on a movie!");
}

@end
