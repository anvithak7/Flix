//
//  DetailsViewController.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AKPickerView.h"
#import "Movie.h"

// Note to reader: lots of older implementations of ideas are still here in case I could figure out what the issues were.
// Anything with similarMoviesPicker was an attempt at using AKPickerView, which seems to not be maintained anymore and has some issues.
// I also tried using a scrollView, which didn't seem to display the images.
// Note to self for future attempts: all of these attempts compiled, but no images were displayed at all no matter what I tried/Googled (spent like five hours on this feature :( - try collectionView inside scrollView or just make a collectionView that statically displays maybe three similar movies.
@interface DetailsViewController () // <AKPickerViewDelegate, AKPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator1;
@property (weak, nonatomic) IBOutlet UILabel *backdropNoImageLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterNoImageLabel;
// @property (weak, nonatomic) IBOutlet UIScrollView *scrollview; Tried using a scrollview for the similar movies, will try again by adding a collectionView too because I'm exhausted.
@property (nonatomic, strong) NSArray *similarMovies;
@property (nonatomic, strong) NSMutableArray *ImageArray;
@property (nonatomic, strong) UIImageView *similarImagePoster;
/* @property (nonatomic, strong) AKPickerView *similarMoviesPicker;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *highlightedFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) CGFloat fisheyeFactor; */ // This is related to the AKPickerView code, which didn't end up working out.

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* This is related to the AKPicker set up programmatically:
     CGRect movieFrame = CGRectMake(0, self.view.frame.size.height / 2, self.posterView.frame.size.width, self.posterView.frame.size.height);
    self.similarMoviesPicker = [[AKPickerView alloc] initWithFrame:movieFrame];
    [self.view addSubview:self.similarMoviesPicker];
    self.similarMoviesPicker.delegate = self;
    self.similarMoviesPicker.dataSource = self;
    [self.similarMoviesPicker setBackgroundColor: [UIColor colorNamed:@"blue"]]; */
    // Will later put the below in a model class (later lab).
    [self.loadingIndicator1 startAnimating];
    //[self fetchSimilarMovies];
    /* The below is related to the scrollView attempt, where I put each image into an array and then tried displaying each in the scrollView (from Stack Overflow
    for (int i = 0; i < self.similarMovies.count; i++) {
        NSString *highBaseURLString = @"https://image.tmdb.org/t/p/original";
        NSDictionary *movie = self.similarMovies[i];
        NSString *posterURLString = movie[@"poster_path"];
        NSString *fullHighURLString = [highBaseURLString stringByAppendingString:posterURLString];
        NSURL *urlLarge = [NSURL URLWithString:fullHighURLString];
        [self.similarImagePoster setImageWithURL:urlLarge];
       UIImage *image = self.similarImagePoster.image;
       [self.ImageArray addObject:image];
    } */
    
    /* This is part of the style for the AKPicker
     self.similarMoviesPicker.interitemSpacing = 20.0;
    self.similarMoviesPicker.fisheyeFactor = 0.001;
    self.similarMoviesPicker.pickerViewStyle = AKPickerViewStyle3D;
    [self.similarMoviesPicker reloadData]; */
    // Only if the poster url exists, we want to display it.
    
    if (!self.movie.lowResPosterURL && !self.movie.highResPosterURL && !self.movie.lowResBackdropURL && !self.movie.highResBackdropURL) {
        // Worst case, we have to tell users that no image is available.
        self.backdropView.image = nil;
        self.posterView.image = nil;
        self.backdropNoImageLabel.alpha = 1;
        self.posterNoImageLabel.alpha = 1;
    } else {
        [self loadPosterImage];
        [self loadBackdropImage];
    }
    // Set the below based on the information from the Movie
    self.titleLabel.text = self.movie.title;
    self.synopsisLabel.text = self.movie.synopsis;
    self.releaseLabel.text = self.movie.releaseDate;
    self.ratingLabel.text = self.movie.ratings;
    //Expand the boxes to fit in more text!
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    [self.releaseLabel sizeToFit];
    [self.ratingLabel sizeToFit];
    [self.loadingIndicator1 stopAnimating];
}

/*
 This is part of the scrollView attempt:
- (void)viewWillAppear:(BOOL)animated {
    for (int i = 0; i < self.ImageArray.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollview.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollview.frame.size;
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        UIImage *image = [self.ImageArray objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
        [imageView setFrame:CGRectMake(0, 0, frame.size.width,frame.size.height )];
        [subview addSubview:imageView];
        [self.scrollview addSubview:subview];
    }
    self.scrollview.contentSize = CGSizeMake(self.scrollview.frame.size.width * self.ImageArray.count, self.scrollview.frame.size.height);
    self.scrollview.contentOffset=CGPointMake (self.scrollview.frame.size.width, 0);
} */

- (void) loadBackdropImage {
    self.backdropView.image = nil; // Clear out the previous one before downloading the new one.
    NSURLRequest *backdropRequestSmall = [NSURLRequest requestWithURL:self.movie.lowResBackdropURL];
    NSURLRequest *backdropRequestLarge = [NSURLRequest requestWithURL:self.movie.highResBackdropURL];

    __weak DetailsViewController *weakSelf = self;

    [self.backdropView setImageWithURLRequest:backdropRequestSmall placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
       // smallImageResponse will be nil if the smallImage is already available
       // in cache (might want to do something smarter in that case).
       weakSelf.backdropView.alpha = 0.0;
       weakSelf.backdropView.image = smallImage;
       
       [UIView animateWithDuration:0.1 animations:^{
           weakSelf.backdropView.alpha = 1.0;
                            
       } completion:^(BOOL finished) {
        // The AFNetworking ImageView Category only allows one request to be sent at a time
        // per ImageView. This code must be in the completion block.
        [weakSelf.backdropView setImageWithURLRequest:backdropRequestLarge placeholderImage:smallImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
            weakSelf.backdropView.image = largeImage;
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
           // do something for the failure condition of the large image request
           // possibly setting the ImageView's image to a default image
       }];
    }];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
       // do something for the failure condition
       // possibly try to get the large image
    }];
}

- (void) loadPosterImage {
    self.posterView.image = nil; // Clear out the previous one before downloading the new one.
    NSURLRequest *posterRequestSmall = [NSURLRequest requestWithURL:self.movie.lowResPosterURL];
    NSURLRequest *posterRequestLarge = [NSURLRequest requestWithURL:self.movie.highResPosterURL];

    __weak DetailsViewController *weakSelf = self;

    [self.posterView setImageWithURLRequest:posterRequestSmall placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
       // smallImageResponse will be nil if the smallImage is already available
       // in cache (might want to do something smarter in that case).
       weakSelf.posterView.alpha = 0.0;
       weakSelf.posterView.image = smallImage;
       
       [UIView animateWithDuration:0.1 animations:^{
           weakSelf.posterView.alpha = 1.0;
                            
       } completion:^(BOOL finished) {
        // The AFNetworking ImageView Category only allows one request to be sent at a time
        // per ImageView. This code must be in the completion block.
        [weakSelf.posterView setImageWithURLRequest:posterRequestLarge placeholderImage:smallImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
            weakSelf.posterView.image = largeImage;
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
           // do something for the failure condition of the large image request
           // possibly setting the ImageView's image to a default image
       }];
    }];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
       // do something for the failure condition
       // possibly try to get the large image
    }];
}

/* - (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView {
    return self.similarMovies.count;
} */

/*- (UIImage *)pickerView:(AKPickerView *)pickerView imageForItem:(NSInteger)item {
    NSString *highBaseURLString = @"https://image.tmdb.org/t/p/original";
    NSDictionary *movie = self.similarMovies[item];
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullHighURLString = [highBaseURLString stringByAppendingString:posterURLString];
    NSURL *urlLarge = [NSURL URLWithString:fullHighURLString];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];
    CGRect movieFrame = self.posterView.frame;
//    UIImageView *someImageView = [[UIImageView alloc] initWithFrame:movieFrame];
    [self.similarImagePoster setImageWithURL:urlLarge];
//    [someImageView.image setImage:requestLarge];
    // [self.view addSubview:someImageView];
//    UIImageView *fakeImageView = [UIImageView :requestLarge]
//    [ setImageWithURLRequest:requestLarge];
    return self.similarImagePoster.image;
} */


- (void)fetchSimilarMovies {
    // The loading indicator starts up when something is loading/fetching from network.
    //[self.loadingIndicator startAnimating];
    NSString *similarURLHalf = [@"https://api.themoviedb.org/3/movie/ stringByAppendingString:backdropURLString" stringByAppendingString:[NSString stringWithFormat:@"%@",self.movie.movieID]];
    NSString *similarMoviesURLString = [similarURLHalf stringByAppendingString:@"/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    NSURL *url = [NSURL URLWithString:similarMoviesURLString];
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
               // Show some "No similar movies found" label instead.
           }
           else { // The API gave us something back! In the form of a dictionary!
               NSLog(@"Something happened");
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // %@ means specifying an object.
               NSLog(@"%@", dataDictionary);
               self.similarMovies = dataDictionary[@"results"];
               //[self.similarMoviesPicker reloadData];

               // Store the movies in a property to use elsewhere
               // Reload your table view data
           }
        //[self.refreshControl endRefreshing];
        //[self.loadingIndicator stopAnimating];
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
