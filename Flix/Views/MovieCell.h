//
//  MovieCell.h
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/23/21.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface MovieCell : UITableViewCell
@property (nonatomic, strong) Movie *movie;
// The below features have to belong to each cell, and not to the overall Movies View Controller.
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end

NS_ASSUME_NONNULL_END
