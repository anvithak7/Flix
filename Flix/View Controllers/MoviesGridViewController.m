//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/24/21.
//

#import "MoviesGridViewController.h"
#import "DetailsViewController.h"
#import "MoviesGridCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *movies;
// @property (nonatomic, strong) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *movieSearchBar;
// @property (strong, nonatomic) NSArray *filteredData;
// @property (nonatomic) BOOL searchBarOn;
// data and filteredData are part of the attempt to create a search bar.

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.movieSearchBar.delegate = self;
    [self fetchMovies];
    // We're setting the sizes of the items.
    // The width of the collectionView will change according to the size of the phone.
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    CGFloat postersPerRow = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerRow - 1)) / postersPerRow;
    CGFloat itemHeight = 1.5 * itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    // self.filteredData = self.data;
}

- (void)fetchMovies {
    // The loading indicator starts up when something is loading/fetching from network.
    //[self.loadingIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/popular?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
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
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to Load Movies" message:@"The internet connection appears to be offline. Please reconnect and try again!" preferredStyle:(UIAlertControllerStyleAlert)];
               
               UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) { [self fetchMovies];
                   // handle cancel response here. Doing nothing will dismiss the view.
                                                                 }];
               [alert addAction:tryAgainAction];
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
               NSLog(@"%@", [error localizedDescription]); // If there's an error, print it out.
           }
           else { // The API gave us something back! In the form of a dictionary!
               NSLog(@"Something happened");
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // %@ means specifying an object.
               NSLog(@"%@", dataDictionary);
               self.movies = dataDictionary[@"results"];
               [self.collectionView reloadData];
               //[self.tableView reloadData];
               // Get the array of movies
               // Store the movies in a property to use elsewhere
               // Reload your table view data
           }
        //[self.refreshControl endRefreshing];
        //[self.loadingIndicator stopAnimating];
       }];
    [task resume];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie; // Passing over movie to next view controller.
    NSLog(@"Tapping on a movie!");
}

// nonnull --kind of is for compatability with Swift (can be deleted).
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MoviesGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviesGridCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.item];
    NSString *baseURLString = @"https:image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.gridPosterView.image = nil; // Clear out the previous one before downloading the new one.
    [cell.gridPosterView setImageWithURL:posterURL];
    //[self.loadingIndicator stopAnimating];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

/* More search bar functionality that does not work yet.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject containsString:searchText];
        }];
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
        NSLog(@"%@", self.filteredData);
    }
    else {
        self.filteredData = self.movies;
    }
    [self.collectionView reloadData];
 
}
 */

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.movieSearchBar.showsCancelButton = YES;
}

 - (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.movieSearchBar.showsCancelButton = NO;
    self.movieSearchBar.text = @"";
    [self.movieSearchBar resignFirstResponder];
}

@end
