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
@property (weak, nonatomic) IBOutlet UILabel *viewerLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Will later put the below in a model class (later lab).
    NSString *baseURLString = @"https:image.tmdb.org/t/p/w500";
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    self.backdropView.image = nil;
    self.posterView.image = nil; // Clear out the previous one before downloading the new one.
    [self.backdropView setImageWithURL:backdropURL];
    [self.posterView setImageWithURL:posterURL];

    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    self.releaseLabel.text = self.movie[@"release_date"];
    //self.ratingLabel.text = self.movie[@"vote_average"];
    //NSString *viewerCount = self.movie[@"vote_count"];
    //self.viewerLabel.text = [viewerCount stringByAppendingString:@" viewers"];
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
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
