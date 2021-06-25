//
//  DetailsViewController.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator1;
@property (weak, nonatomic) IBOutlet UILabel *backdropNoImageLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterNoImageLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Will later put the below in a model class (later lab).
    [self.loadingIndicator1 startAnimating];
    // Only if the poster url exists, we want to display it.
    BOOL posterExists = [self.movie[@"poster_path"] isKindOfClass:[NSString class]];
    BOOL backdropExists = [self.movie[@"backdrop_path"] isKindOfClass:[NSString class]];
    if (posterExists && backdropExists) {// If both exist, everything is normal.
        [self loadBackdropImage:self.movie[@"backdrop_path"]];
        [self loadPosterImage:self.movie[@"poster_path"]];
    } else if (posterExists && !backdropExists) { // We can use the poster for the backdrop if one doesn't exist.
        [self loadBackdropImage:self.movie[@"poster_path"]];
        [self loadPosterImage:self.movie[@"poster_path"]];
    } else if (!posterExists && backdropExists) { // Or vice-versa
        [self loadBackdropImage:self.movie[@"backdrop_path"]];
        [self loadPosterImage:self.movie[@"backdrop_path"]];
    } else if (!posterExists && !backdropExists) {
        // Worst case, we have to tell users that no image is available.
        self.backdropView.image = nil;
        self.posterView.image = nil;
        self.backdropNoImageLabel.alpha = 1;
        self.posterNoImageLabel.alpha = 1;
    }
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    // Checks for if the release date exists.
    if ([self.movie[@"release_date"] isKindOfClass:[NSString class]]) {
        NSArray *releaseDate = [self.movie[@"release_date"] componentsSeparatedByString:@"-"];
        NSArray *months = [NSArray arrayWithObjects: @"Jan. ", @"Feb. ", @"March ", @"April ", @"May ", @"June ", @"July ", @"Aug. ", @"Sept. ", @"Oct. ", @"Nov. ", @"Dec. ", nil];
        int monthNumber = [releaseDate[1] intValue];
        NSString *releaseMonth = months[monthNumber - 1];
        NSString *releasedOnMonth = [@"Released on " stringByAppendingString:releaseMonth];
        NSString *releasedOnPlusDay = [releasedOnMonth stringByAppendingString:releaseDate[2]];
        //Append comma
        NSString *releasedOnPlusDayComma = [releasedOnPlusDay stringByAppendingString:@", "];
        NSString *finalReleaseDate = [releasedOnPlusDayComma stringByAppendingString:releaseDate[0]];
        self.releaseLabel.text = finalReleaseDate;
    } else {
        self.releaseLabel.text = @"No release date available";
    }
    if (![self.movie[@"vote_count"] isEqual:@0]) {
        // I know the below is highly inefficient; will figure out a better way later. This is brute force for now!
        // Question: is there a faster way of multiple string concatenations?
        NSString *voteAverage = [NSString stringWithFormat: @"%@", self.movie[@"vote_average"]];
        NSString *ratedAndVotes = [@"Rated " stringByAppendingString:voteAverage];
        NSString *ratedAndVotesBy = [ratedAndVotes stringByAppendingString:@" / 10 by "];
        NSString *ratedAndVotesByNumber = [ratedAndVotesBy stringByAppendingString:[NSString stringWithFormat: @"%@", self.movie[@"vote_count"]]];
        NSString *ratedAndVotesByNumberViewers = [ratedAndVotesByNumber stringByAppendingString:@" viewers"];
        self.ratingLabel.text = ratedAndVotesByNumberViewers;
    } else if ([self.movie[@"vote_count"] isEqual:@0]) {
        self.ratingLabel.text = @"No ratings available";
    }
    [self.titleLabel sizeToFit]; //Expand the boxes to fit in more text!
    [self.synopsisLabel sizeToFit];
    [self.releaseLabel sizeToFit];
    [self.ratingLabel sizeToFit];
    [self.loadingIndicator1 stopAnimating];
}

- (void)loadBackdropImage:(NSString*)backdropURLString {
    /*NSString *baseURLString = @"https:image.tmdb.org/t/p/w500"; // We need the base URL in any case.
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString]; */ //Older version (one time only).
    
    // The below loads low resolution first, and then high resolution photos.
    self.backdropView.image = nil;
    NSString *lowBaseURLString = @"https://image.tmdb.org/t/p/w45";
    NSString *highBaseURLString = @"https://image.tmdb.org/t/p/original";
    NSString *fullLowURLString = [lowBaseURLString stringByAppendingString:backdropURLString];
    NSString *fullHighURLString = [highBaseURLString stringByAppendingString:backdropURLString];
    NSURL *urlSmall = [NSURL URLWithString:fullLowURLString];
    NSURL *urlLarge = [NSURL URLWithString:fullHighURLString];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];

    __weak DetailsViewController *weakSelf = self;

    [self.backdropView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       weakSelf.backdropView.alpha = 0.0;
                                       weakSelf.backdropView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.1
                                                        animations:^{
                                                            
                                                            weakSelf.backdropView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.backdropView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
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

- (void) loadPosterImage:(NSString*)posterURLString {
    /*NSString *baseURLString = @"https:image.tmdb.org/t/p/w500"; // We need the base URL in any case.
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; */
    self.posterView.image = nil; // Clear out the previous one before downloading the new one.
    NSString *lowBaseURLString = @"https://image.tmdb.org/t/p/w45";
    NSString *highBaseURLString = @"https://image.tmdb.org/t/p/original";
    NSString *fullLowURLString = [lowBaseURLString stringByAppendingString:posterURLString];
    NSString *fullHighURLString = [highBaseURLString stringByAppendingString:posterURLString];
    NSURL *urlSmall = [NSURL URLWithString:fullLowURLString];
    NSURL *urlLarge = [NSURL URLWithString:fullHighURLString];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];

    __weak DetailsViewController *weakSelf = self;

    [self.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       weakSelf.posterView.alpha = 0.0;
                                       weakSelf.posterView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.1
                                                        animations:^{
                                                            
                                                            weakSelf.posterView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.posterView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
