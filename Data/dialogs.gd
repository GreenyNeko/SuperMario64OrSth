extends Node

var dialogs = [dialogIntro, dialogTrees, dialogSwimming, dialogCrouch, dialogStarToad, dialogYoshi,
	dialogCannonBobOmb, dialogSpawnBobOmb, dialogChainChomp, dialogPunching, dialogCButtons, dialogFence,
	dialogWingCapBoBIsland, dialogLedgeGrab, dialogSigns, dialogRedCoins, dialogSpinningHeart,
	dialogWingCapBoB, dialogCoinRingSecrets, dialogWFToad,
]

func dialogIntro(TextBox):
	TextBox.text.append("Game made with Godot Engine & LibSM64.\nAssets are from various places.")
	TextBox.text.append("Shaders made\nby GreenyNeko\nObject & Enemy AI\nby GreenyNeko")
	TextBox.text.append("Programming\nby GreenyNeko\nSpecial thanks to the people of LibSM64 and its Godot version.")
	TextBox.text.append("As well as SimpleFlips for informing me about the contest.")
	TextBox.text.append("Enjoy! :3\n\n\n\n\n       ~GreenyNeko")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogTrees(TextBox):
	TextBox.text.append("Oh, are you interested in how the trees work? This one was doozy. ")
	TextBox.text.append("So, the way poles and trees work is that Mario has action states. ")
	TextBox.text.append("These action states determine what happens to Mario.")
	TextBox.text.append("You would think that it would be as simple as setting Mario's action  to  pole grab actions.")
	TextBox.text.append("It's not that simple though. Certain actions in Super Mario 64 require arguments.")
	TextBox.text.append("I'm not sure what arguments the pole interactions need.")
	TextBox.text.append("But it can be assumed that a reference to the object needs to be passed.")
	TextBox.text.append("This is a bit complicated in LibSM64...\nSo, most attempts of resulted in crashes.")
	TextBox.text.append("You may wonder how it is that the trees work then.")
	TextBox.text.append("Well, the solution to that is abusing the action state of Mario.")
	TextBox.text.append("If Mario's action state is set to an unknown state a few things occur.")
	TextBox.text.append("First of all, physics do not apply, like movement or gravity.")
	TextBox.text.append("However, manual changes to the position or velocity work.")
	TextBox.text.append("Additionally Mario doesn't play the default animations.")
	TextBox.text.append("You gain the ability to choose it instead.")
	TextBox.text.append("Thus if Mario jumps into a tree his state is set to unknown and the animation to grab onto pole.")
	TextBox.text.append("However, we can't move up or down, jump off, or drop off.")
	TextBox.text.append("We have to implement all of this ourselves.")
	TextBox.text.append("To be fair, moving up and down with ^ and _ on the stick is not the problem.")
	TextBox.text.append("Playing the animation is simple enough as well. Even playing the sound every few moments.")
	TextBox.text.append("How do we determine the top and the groudn though?")
	TextBox.text.append("Mario would be able to climb infinitely in both directions.")
	TextBox.text.append("Well, we can detect when Mario leaves the hitbox. There's two issues I came across though.")
	TextBox.text.append("During a handstand Mario teleports down in the animation. This is odd and needs fixing.")
	TextBox.text.append("I also had the issue to make sure that the tree knows Mario is on it and not another one. ")
	TextBox.text.append("Resulted in Mario being both in handstand and climbing.")
	TextBox.text.append("Now for the bottom... even if Mario leaves the hitbox he still needs to be above ground.")
	TextBox.text.append("It was funny to see Mario go out of bounds while climbing, loosing and gaining the hat.")
	TextBox.text.append("There were some shenanigans with not being able to grab.")
	TextBox.text.append("I added a threshold where Mario drops off when climbing down. Seems to work.")
	TextBox.text.append("And then we come down to rotating Mario and the moves he can perform on trees and poles.")
	TextBox.text.append("The issue with rotation is, there are many ways to rotate Mario.")
	TextBox.text.append("However, most of them don't work in the unknown state. So, that took some trial and error.")
	TextBox.text.append("Next issue: Rotating Mario in the unknown state does not reflect Mario's actual rotation.")
	TextBox.text.append("So, Mario moves where he would've moved before, despite the rotation.")
	TextBox.text.append("We can compensate for that but Mario will also have his velocity set to 0.")
	TextBox.text.append("Hence, I had to overwrite the velocity as well to what was neede based on the moves.")
	TextBox.text.append("I couldn't find a [jump off of pole] action, so I went with the jump action.")
	TextBox.text.append("Of course, that one goes the wrong way at first, so I had to adjust velocity.")
	TextBox.text.append("Also,  the backflip action I used for handstand jumping off goes the wrong way.")
	TextBox.text.append("Had to flip velocity here too.")
	TextBox.text.append("You can do some cool stuff by trying out different things...")
	TextBox.text.append("but it's quite a bit of work making it all yourelf and integrating it as well.")
	TextBox.text.append("I'm proud of how it turned out though.")
	TextBox.text.append("Now the only question is how would you make carrying objects work... huff.")
	TextBox.text.append("Well... thank you for coming to my TED talk. I hope I didn't bore you or make you fall asleep.")
	TextBox.text.append("Would be nice if you enjoyed the tech-talk and didn't just spam @, right?")
	TextBox.init(0.2, 0.2, false, 400, 300)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.POLE_EXPLANATION)

func dialogSwimming(TextBox):
	TextBox.text.append("Swimming Lessons!\nTap @ to do the breast stroke. If... wait nobody cares about water levels anyways...")
	TextBox.init(0.2, 0.2, false, 400, 300)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.MISSING_WATER_MOVEMENT)

func dialogCrouch(TextBox):
	TextBox.text.append("Hey! If you plan to jump up the castle be warned.\n\n(Specifically, you SimpleFlips!)")
	TextBox.text.append("The model used for this level does not differentiate between mountains and grass.")
	TextBox.text.append("This means the mountains aren't slippery. You might not be able to build enough speed.")
	TextBox.text.append("On the upside (heh) the mountain on the left side with the waterfall is easier to climb.")
	TextBox.init(0.2, 0.2, false, 400, 300)
	GameManager.Instance().trollMenu.unlock(TrollMenu.TROLL.BROKEN_GROUND_TYPE)

func dialogStarToad(TextBox):
	TextBox.text.append("Hey, Mario! I don't have a star but if you want we can pretend I have one.")
	TextBox.text.append("Hey Mario! You want a Power star? Sure, I have found this one right here.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogYoshi(TextBox):
	TextBox.text.append("Oh hi, Mario!\nIt's been a long time since our adventures.")
	TextBox.text.append("You think I would give you 99 lives and some special moves?")
	TextBox.text.append("...")
	TextBox.text.append("I still remember what you did to my brethren.")
	TextBox.text.append("...")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogCannonBobOmb(TextBox):
	TextBox.text.append("Hey, you! It's dangerous ahead, so listen up! Take my advice.")
	TextBox.text.append("Cross the two bridges ahead, then watch for falling water bombs.")
	TextBox.text.append("The Big Bob-omb at the top of the mountain is very powerful--don't let him grab you!")
	TextBox.text.append("We're Bob-omb Buddies, and we're on your side. ")
	TextBox.text.append("You can talk to us whenever you'd like to!")
	TextBox.text.append("Hm? You expected something to happen? No, just vanilla text.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogSpawnBobOmb(TextBox):
	TextBox.text.append("Watch out! If you wander around here, you're liable to be plastered by a water bomb! ")
	TextBox.text.append("Those enemy Bob-ombs love to fight, and they're always finding ways to attack. ")
	TextBox.text.append("This meadow has become a battlefield ever since the Big Bob-omb got his paws on the Power Star.")
	TextBox.text.append("Can you recover the Star for us? Cross the bridge and go left up the path to find the Big Bob-omb.")
	TextBox.text.append("Please come back to see me after you've retrieved the Power Star!")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogChainChomp(TextBox):
	TextBox.text.append("BEWARE OF CHAIN CHOMP Extreme Danger!")
	TextBox.text.append("Get close and press §^ for a better look. Scary, huh?")
	TextBox.text.append(" See the Red Coin on top of the stake? ")
	TextBox.text.append("When you collect eight of them, a Power Star will appear in the meadow across the bridge.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogPunching(TextBox):
	TextBox.text.append("You can punch enemies to knock them down. Press @ to jump, ² to punch. Press @ then ² to Kick.")
	TextBox.text.append("To pick something up, press ², too.  To throw something you're holding, press ² again.")
	TextBox.text.append("If you pause and press ^^vv<><> on the stick and then @ ². Something might happen.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogCButtons(TextBox):
	TextBox.text.append("There are four camera, or [§,] Buttons. Press §^ to look around using the Control Stick.")
	TextBox.text.append("You'll usually see Mario through Lakitu's camera. It is the camera recommended for normal play.")
	TextBox.text.append("You can change angles by pressing §>.")
	TextBox.text.append("If you press €, the view switches to Mario's camera, which is directly behind him.")
	TextBox.text.append("Press € again to return to Lakitu's camera.")
	TextBox.text.append("Press §_ to see Mario from afar, using either Lakitu's or Mario's view.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogFence(TextBox):
	TextBox.text.append("No visitors allowed, by decree of the Big Bob-omb")
	TextBox.text.append("I shall never surrender my Stars, for they hold the power of the castle in their glow.")
	TextBox.text.append("They were a gift from Bowser, the Koopa King himself, and they lie well hidden within my realm. ")
	TextBox.text.append("Not a whisper of their whereabouts shall leave my lips. Oh, all right, perhaps one hint:")
	TextBox.text.append("Heed the Star names at the beginning of the course.\n\n --The Big Bob-omb")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogWingCapBoBIsland(TextBox):
	TextBox.text.append("When you put on the Wing Cap that comes from a red block, do the Triple Jump to soar high into")
	TextBox.text.append(" the sky. Use the Control Stick to guide Mario. Pull back to to fly up, press forward to nose down, ")
	TextBox.text.append("and press ³ to land.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogLedgeGrab(TextBox):
	TextBox.text.append("You can grab on to the edge of a cliff or ledge with your fingertips and hang down from it.")
	TextBox.text.append("To drop from the edge, either press the Control Stick in the direction of Mario's back")
	TextBox.text.append("or press the ³ Button. . To get up onto the ledge,")
	TextBox.text.append("either press Up on the Control Stick or press @ as soon as you grab the ledge to climb up quickly.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogSigns(TextBox):
	TextBox.text.append("To read a sign,.. well that's pointless.")
	TextBox.text.append("You can treat certain creatures as signs as well.")
	TextBox.text.append("Wait, that came out wrong... You get the idea though.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogRedCoins(TextBox):
	TextBox.text.append("The shadowy star in front of you is a [Star Marker.]")
	TextBox.text.append("When you collect all 8 Red Coins, the Star will appear here.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogSpinningHeart(TextBox):
	TextBox.text.append("Collect as many coins as possible! They'll refill your Power Meter.")
	TextBox.text.append("You can check to see how many coins you've collected in each of the 15 enemy worlds.")
	TextBox.text.append("You can also recover power by touching the Spinning Heart.")
	TextBox.text.append("The faster you run through the heart, the more power you'll recover.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogWingCapBoB(TextBox):
	TextBox.text.append("There are special Caps in the red, green and blue blocks.")
	TextBox.text.append("Step on the switches in the hidden courses to activate the Cap Blocks.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogCoinRingSecrets(TextBox):
	TextBox.text.append("Sometimes, if you pass through a coin ring or find a secret point in a course,")
	TextBox.text.append("a red number will appear. If you trigger five red numbers, a secret Star will show up.")
	TextBox.init(0.2, 0.2, false, 400, 300)

func dialogWFToad(TextBox):
	TextBox.text.append("Thank you, Mario!\n\nBut our Whomp's Fortress is in another castle!")
	TextBox.init(0.2, 0.2, false, 400, 300)
