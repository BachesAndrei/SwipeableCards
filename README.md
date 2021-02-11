# SwipeableCards

This is a demo project designed to offer a customizable implementation of swipeable cards. It adds convenient functionality such as a UITableView-style dataSource/delegate interface for loading views dynamically, and efficient view loading, unloading.

This project is not developded as a framework that can be integrated in the the app because it aims to give access to the source code in order to further improve or customize the animations to better respond to design requirements.

![](demo.gif)


After copying the source files to your project, the SwipeableCards can be used both programmatically or by storyboards. You need to add a SwipeableCardViewContainer object your ViewController and make sure it implements SwipeableCardViewDataSource and SwipeableViewContainerDelegate

To further customize the design of the cards, you can modify TipCardView files. 
If you want to change the swipe animations, you can modify SwipeableCardView or SwipeableCardViewContainer files

