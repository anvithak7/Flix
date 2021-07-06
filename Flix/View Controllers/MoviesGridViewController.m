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
#import "Movie.h"
#import "MovieAPIManager.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *movies;
@property (nonatomic, strong) NSMutableArray *filteredData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *movieSearchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

// data and filteredData are part of the attempt to create a search bar.

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.movieSearchBar.delegate = self;
    // Initializing with searchResultsController set to nil means that
    // searchController will use this view controller to display the search results
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
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0]; // addSubview allows you to nest views. insertSubview layers at whatever index.
}

- (void)fetchMovies {
    MovieAPIManager *manager = [MovieAPIManager new];
    [manager fetchPopularMovies:^(NSMutableArray *movies, NSError *error) {
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
        self.filteredData = self.movies;
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    Movie *movie = self.filteredData[indexPath.row];
    DetailsViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie; // Passing over movie to next view controller.
    NSLog(@"Tapping on a movie!");
}

// nonnull --kind of is for compatability with Swift (can be deleted).
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MoviesGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviesGridCollectionViewCell" forIndexPath:indexPath];
    Movie *movie = self.filteredData[indexPath.item];
    cell.gridPosterView.image = nil; // Clear out the previous one before downloading the new one.
    [cell.gridPosterView setImageWithURL:movie.highResPosterURL];
    //[self.loadingIndicator stopAnimating];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        // Predicate - a filtering function (whether the dictionary should be included or not)
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Movie *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.title containsString:searchText];
        }];
        // Going through each Movie in movies and filtering based on the filter defined above
        self.filteredData = (NSMutableArray*) [self.movies filteredArrayUsingPredicate:predicate];
        NSLog(@"%@", self.filteredData);
    }
    else {
        self.filteredData = self.movies;
    }
    [self.collectionView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.movieSearchBar.showsCancelButton = YES;
}

 - (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.movieSearchBar.showsCancelButton = NO;
    self.movieSearchBar.text = @"";
    [self.movieSearchBar resignFirstResponder];
}

@end
