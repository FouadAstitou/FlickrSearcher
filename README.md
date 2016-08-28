# FlickrSearcher

Swift 2.2
Xcode 7.3.1
iOS Deployment Target 9.3

=== App description. ===
This is an app that uses the Flickr API to allow user searching for photos with specific words.
The searching is done using a textfield inside the navigation bar. 
The search url is construsted two return two sizes of the same image.
A small size is used to be displayed in a collection view. The larger size is used in the detail view.
The app uses an infinite scroll view to display the results in the collection view.
In the detail view i also implemented the option to share the photo through social media.

=== Libraries ===
For Reachability, i used the Reachability.Swift file from Ashley Mills. For all the rest i used the Apple libraries.
I prefer to use Apple's libraries as much as possible, because i'm still new at programming. That way i keep learning more about
how the code works. CocoaPods that i have used before which can be used to do the same are:
- Alamofire
- SwiftyJSON
- SDWebImage

=== Building the project ===
Just unzip or clone and double click on FlickrSearecher.xcodeproj.





