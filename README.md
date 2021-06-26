# Project 2 - *Flix*

**Flix** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **26** hours spent in total

## User Stories

The following **required** functionality is complete:

- [X] User sees an app icon on the home screen and a styled launch screen.
- [X] User can view a list of movies currently playing in theaters from The Movie Database.
- [X] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [X] User sees a loading state while waiting for the movies API.
- [X] User can pull to refresh the movie list.
- [X] User sees an error message when there's a networking error.
- [X] User can tap a tab bar button to view a grid layout of Movie Posters using a CollectionView.

The following **optional** features are implemented:

- [X] User can tap a poster in the collection view to see a detail screen of that movie
- [ ] User can search for a movie. (in progress)
- [X] All images fade in as they are loading.
- [ ] User can view the large movie poster by tapping on a cell.
- [X] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [X] Customize the selection effect of the cell.
- [X] Customize the navigation bar.
- [ ] Customize the UI.
- [ ] User can view the app on various device sizes and orientations.
- [ ] Run your app on a real device.

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Created a scrollable similar movies and "If you liked this, check out..." view in the Details page using the Similar Movies and Recommendations. I tried this in several ways, including using another pod, but I could not get it work as desired.
2. What are better ways of implementing the search bar so that you can search by genre, as well as by movie title?
3. How can we build a database of all movies and have a way of memory persisting across loadings of the application so that users can create an account and make a list of movies watched and movies to watch?

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://g.recordit.co/cGmY98LexY.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />
<img src='http://g.recordit.co/ga7atNX9lU.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />
<blockquote lang="en"><a href="http://g.recordit.co/cGmY98LexY.gif">Flix</a></blockquote>
<blockquote class="imgur-embed-pub" lang="en" data-id="a/APjGYm5"  ><a href="//imgur.com/a/APjGYm5">Flix - Without Wifi</a></blockquote>
GIF created with [Kap](https://getkap.co/).

## Notes

Describe any challenges encountered while building the app.
I had a lot of goals for this app, and I especially wanted to be able to create a Netflix-like similar movies view in the Details page and add something similar for movie recommendations. I started by brainstorming ways to do this and then researching those ideas to see if anyone had ideas, and I found that some ideas (like nesting collection views inside scrolling views because scrolling view is a parent) were considered "bad design" by some users on Stack Overflow, so I spoke with a TA on ideas that we could implement. A lot of them required autolayout, which we are going to learn next week in detail. We found a pod that was supposed to create a horizontal picker view, which could show the similar movies, and we spent some time implementing it, and a lot of time trying to debug it. It turned out that AKPickerView was archived by the creator and was last updated 6 years ago, but even then, some people seemed to say it worked, so we continued trying to find ways of debugging (everything would compile but no picker view would show up in the screen (even after adding subviews and trying other ideas)). Eventually, we decided to try another tactic, using a scroll view, for which the code made logical sense but also didn't seem to work to display anything. I spent too many hours trying to develop this feature, and although I wasn't able to make it work within the time we had, I learned a lot. There has to be an easier way of doing it! Because of this, I didn't have time to fully implement the search bar, although it has some functionality.

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [AKPickerView](https://github.com/akkyie/AKPickerView)

## License

    Copyright [2021] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
