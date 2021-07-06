//
//  Movie.m
//  Flix
//
//  Created by Anvitha Kachinthaya on 6/30/21.
//

#import "Movie.h"

@implementation Movie

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    self.movieID = dictionary[@"movie_id"];
    self.title = dictionary[@"original_title"];
    self.synopsis = dictionary[@"overview"];
    // Set the other properties from the dictionary
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *backdropURLString = dictionary[@"backdrop_path"];
    NSString *lowBaseURLString = @"https://image.tmdb.org/t/p/w45";
    NSString *highBaseURLString = @"https://image.tmdb.org/t/p/original";
    BOOL posterExists = [posterURLString isKindOfClass:[NSString class]];
    BOOL backdropExists = [backdropURLString isKindOfClass:[NSString class]];
    // We want to make sure that we actually do have strings for the poster and backdrop, or we have to use one for the other.
    if (posterExists && !backdropExists) {
        backdropURLString = posterURLString;
    }
    if (!posterExists && backdropExists) {
        posterURLString = backdropURLString;
    }
    // Make sure the two strings exist
    posterExists = [posterURLString isKindOfClass:[NSString class]];
    backdropExists = [backdropURLString isKindOfClass:[NSString class]];
    if (posterExists && backdropExists) {
        // Setting the low and high resolution versions of the poster URL string.
        NSString *fullLowPosterURLString = [lowBaseURLString stringByAppendingString:posterURLString];
        NSString *fullHighPosterURLString = [highBaseURLString stringByAppendingString:posterURLString];
        self.lowResPosterURL = [NSURL URLWithString:fullLowPosterURLString];
        self.highResPosterURL = [NSURL URLWithString:fullHighPosterURLString];
        
        // Setting the low and high resolution versions of the backdrop URL string.
        NSString *fullLowBackdropURLString = [lowBaseURLString stringByAppendingString:backdropURLString];
        NSString *fullHighBackdropURLString = [highBaseURLString stringByAppendingString:backdropURLString];
        self.lowResBackdropURL = [NSURL URLWithString:fullLowBackdropURLString];
        self.highResBackdropURL = [NSURL URLWithString:fullHighBackdropURLString];
    } else if (!posterExists && !backdropExists) {
        NSString *empty = @"";
        self.lowResPosterURL = [NSURL URLWithString:empty];
        self.highResPosterURL = [NSURL URLWithString:empty];
        self.lowResBackdropURL = [NSURL URLWithString:empty];
        self.highResBackdropURL = [NSURL URLWithString:empty];
    }
    
    if ([dictionary[@"release_date"] isKindOfClass:[NSString class]]) {
        NSArray *releaseDate = [dictionary[@"release_date"] componentsSeparatedByString:@"-"];
        NSArray *months = [NSArray arrayWithObjects: @"Jan. ", @"Feb. ", @"March ", @"April ", @"May ", @"June ", @"July ", @"Aug. ", @"Sept. ", @"Oct. ", @"Nov. ", @"Dec. ", nil];
        int monthNumber = [releaseDate[1] intValue];
        NSString *releaseMonth = months[monthNumber - 1];
        NSString *releasedOnMonth = [@"Released on " stringByAppendingString:releaseMonth];
        NSString *releasedOnPlusDay = [releasedOnMonth stringByAppendingString:releaseDate[2]];
        //Append comma
        NSString *releasedOnPlusDayComma = [releasedOnPlusDay stringByAppendingString:@", "];
        NSString *finalReleaseDate = [releasedOnPlusDayComma stringByAppendingString:releaseDate[0]];
        self.releaseDate = finalReleaseDate;
    } else {
        self.releaseDate = @"No release date available";
    }
    // Checks for if the release date exists.
    if (![dictionary[@"vote_count"] isEqual:@0]) {
        // I know the below is highly inefficient; will figure out a better way later. This is brute force for now!
        // Question: is there a faster way of multiple string concatenations?
        NSString *voteAverage = [NSString stringWithFormat: @"%@", dictionary[@"vote_average"]];
        NSString *ratedAndVotes = [@"Rated " stringByAppendingString:voteAverage];
        NSString *ratedAndVotesBy = [ratedAndVotes stringByAppendingString:@" / 10 by "];
        NSString *ratedAndVotesByNumber = [ratedAndVotesBy stringByAppendingString:[NSString stringWithFormat: @"%@", dictionary[@"vote_count"]]];
        NSString *ratedAndVotesByNumberViewers = [ratedAndVotesByNumber stringByAppendingString:@" viewers"];
        self.ratings = ratedAndVotesByNumberViewers;
    } else if ([dictionary[@"vote_count"] isEqual:@0]) {
        self.ratings = @"No ratings available";
    }
    return self;
}


+ (NSMutableArray *)moviesWithDictionaries:(NSArray *)dictionaries {
   // Implement this function
    NSMutableArray *movies = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in dictionaries) {
        Movie *movie = [[Movie alloc] initWithDictionary:dictionary];// Call the Movie initializer here
        NSLog(@"%@", movie.title);
        [movies addObject:movie];
    }
    return movies;
}

@end
