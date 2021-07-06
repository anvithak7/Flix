//
//  MoviesViewController.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/23/21.
//

#import "MoviesViewController.h"
#import "DetailsViewController.h"
#import "MovieCell.h"
#import "Movie.h"
#import "UIImageView+AFNetworking.h"
#import "MovieAPIManager.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
// The above says that this class implements the two protocols there and their required methods.
// DataSource - how to show table view contents
// Delegate - how to respond to events (doesn't have required methods.

// nonatomic and strong indicate how the compiler should generate the getter and setter methods.
// No garbage collector, so we have to use reference counting.
// Incrememnt reference counter of movies so it doesn't go away (with strong, increments retain count).
// Most things are nonatomic (very rarely otherwise).
@property (nonatomic, strong) NSMutableArray *movies; // Creates a private instance variable with a getter and setter method.
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation MoviesViewController

// Lifecycle methods are called automatically by the system.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self ; // The view controller is the data source and delegate!
    self.tableView.delegate = self;
    [self.loadingIndicator startAnimating];
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // addSubview allows you to nest views. insertSubview layers at whatever index.
}

- (void)fetchMovies {
    MovieAPIManager *manager = [MovieAPIManager new];
    [manager fetchNowPlaying:^(NSMutableArray *movies, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to Load Movies" message:@"The internet connection appears to be offline. Please reconnect and try again!" preferredStyle:(UIAlertControllerStyleAlert)];
            
            UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) { [self fetchMovies];
                // handle cancel response here. Doing nothing will dismiss the view.
                                                              }];
            [alert addAction:tryAgainAction];
            
            // The below was the given code, but I wanted to do a try again button instead! (above)
            /*// create a cancel action
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle cancel response here. Doing nothing will dismiss the view.
                                                              }];
            // add the cancel action to the alertController
            [alert addAction:cancelAction];
            // create an OK action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            // add the OK action to the alert controller
            [alert addAction:okAction]; */
            [self presentViewController:alert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
        }
        self.movies = movies;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self.loadingIndicator stopAnimating];
    }];
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
    // The loading indicator pops up when the images and cell values are loading.
    [self.loadingIndicator startAnimating];
    cell.movie = self.movies[indexPath.row];
    [self.loadingIndicator stopAnimating];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { // sender = generic for object that fired the event, and id is the tableview cell!
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    Movie *movie = self.movies[indexPath.row];
    DetailsViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie; // Passing over movie to next view controller.
    NSLog(@"Tapping on a movie!");
}

@end
