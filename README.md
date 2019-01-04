# Every Teen Seen
This app is here to help people come together in the Every Teen Seen 2018 Movement. The goal of this non profit organization is to reduce the amount of suicides in 2018 by 50 percent.
The reason I took on this project was because the owner was super passionate about what he was teaching and I really belived in what he was preaching. Since I believed so much in him I
offered to devlop this app for him completely free in hopes that I too could help make a difference.

## Download In the AppStore
https://itunes.apple.com/us/app/every-teen-seen/id1350070430?mt=8

## Screenshots
![img_1038 2x](https://user-images.githubusercontent.com/31580350/50669272-68811a80-0f81-11e9-84d5-b40d9fdce5c6.png)
![img_1039 2x](https://user-images.githubusercontent.com/31580350/50669273-68811a80-0f81-11e9-87e4-136bf7568085.png)
![img_1040 2x](https://user-images.githubusercontent.com/31580350/50669274-68811a80-0f81-11e9-9b17-b61dcf3b2587.png)
![img_1037 2x](https://user-images.githubusercontent.com/31580350/50669276-6919b100-0f81-11e9-84c1-7d13c4fd9a8b.png)

## Frameworks and Technologies Used 
- Firebase
- Push Notifications
- Coredata 
- Codable / JSONSerialization 
- Mapkit

## Firebase 
Firebase is used by a ton of developers, and at the time I had only used Cloudkit! So, instead using something that I was  familar with I chose to stray outside my comfort zone. After spending some time learning how to implement Firebase  it handles all of my images, push notifications, and authentication. When Firebase Firestore was released I quickly jumped on it because it made querying data even faster, and that meant users didn't have to wait as long! 

## CoreData 
I used CoreData because I wanted the app to be able to save as much information as possible. It was important to me that users didn't have to look at a long loading sign and CoreData helped me do that. I did run into a few hickups with working with Codable and Coredata, but I was able to figure out a way to work around it. 

## Codable / JSONSerialization
When I used Codable for the first time I was so confused! After really diving into it I was able to save myself from writting a ton of code, which every developer wants to do! It does turn out that Codable and Cordata don't like working together. So, I did end up using JSONSerialization for some things, which I think helped in the long run.

## Mapkit
The original use case for the app was supposed to be in Utah so I had to implement Mapkit to request the user's location to ensure that only certin people were downloading it. After some time went by I did decide that the app should be available for anyone who wants to share their activies to the world, as long as they were empowering those who needed it. With that being the case I felt it was important that users were able to filter the events based on their location and only see ones that were close to them. 

## Second App Ever Developed
If you made it this far I want to say thank you for your time and I hope you've had a change to download the app. As time goes on I am hoping that motivated people will use the app more. I am actually going to make it public for everyone who wants hosts events! If you're someone who is a developer or just even used the app please feel free to leave a review and give me any kind of feedback : ) 
