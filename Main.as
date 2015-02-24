package  {
	
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	import flash.filters.GlowFilter;
	
	import flash.net.SharedObject;
	
	public class Main extends Sprite {
		
		private const BULLET_SPEED:uint = 5;
		private var spaceship:spaceship_mc;
		private var bullet:bullet_mc;
		private var isFiring:Boolean = false;
		private var enemy:enemy_mc;		
		private var level:uint = 1;
		private var enemyVector:Vector.<enemy_mc> = new Vector.<enemy_mc>();
		private var enemyToRemove:int = -1;
		
		private var score:uint = 0;
		//private var highScore:uint = 0;
		private var sharedHighScore:SharedObject;
		
		public function Main() {
			// constructor code
		
			sharedHighScore = SharedObject.getLocal('highScore');
			
			if (sharedHighScore.data.score == undefined) {
				sharedHighScore.data.name = "STAN NESI";
				sharedHighScore.data.score = 1220;
				sharedHighScore.data.level = 27;
				
				//trace ("No High Score Found");
				scoreboard_mc.info.text += ".:: ASTRO-PANIC ::. \n\n";
				scoreboard_mc.info.text += "-----------------\n";
				scoreboard_mc.info.text += "HIGH-SCHORE\n";	
				scoreboard_mc.info.text += "BY\n";
				scoreboard_mc.info.text += sharedHighScore.data.name +"\n";
				scoreboard_mc.info.text += sharedHighScore.data.score + "\n\n";
				scoreboard_mc.info.text += "LEVEL :::  " + sharedHighScore.data.level;
			} else {
				scoreboard_mc.info.text += ".:: ASTRO-PANIC ::. \n\n";
				scoreboard_mc.info.text += "-----------------\n";
				scoreboard_mc.info.text += "HIGH-SCHORE\n";	
				scoreboard_mc.info.text += "BY\n";
				scoreboard_mc.info.text += sharedHighScore.data.name +"\n";
				scoreboard_mc.info.text += sharedHighScore.data.score + "\n\n";
				scoreboard_mc.info.text += "LEVEL :::  " + sharedHighScore.data.level;
			}
			
			sharedHighScore.close();
			setSpaceship();
			playLevel();
			addEventListener(Event.ENTER_FRAME, onEnterFrm);
			stage.addEventListener(MouseEvent.CLICK, onMouseClck);
		}

		private function updateBoard():void{
			scoreboard_mc.score.text = score.toString();
			scoreboard_mc.level.text = level.toString();
			if (scoreboard_mc.highscore.text && sharedHighScore.data.score != undefined) {
				scoreboard_mc.highscore.text = sharedHighScore.data.score.toString();;
			}
		}
		
		private function setSpaceship():void {
			spaceship = new spaceship_mc();
			
			addChild(spaceship);
			spaceship.y = 470;
			
			var glow:GlowFilter = new GlowFilter(0x33CCFF, 1, 8, 8, 2, 2);
			spaceship.filters =  new Array(glow);
		}

		private function playLevel():void {
			for (var i:uint = 1; i < level + 3; i++) {
				setEnemy(i);
			}
			updateBoard();
		}

		private function onEnterFrm(e:Event):void {
			spaceship.x = mouseX;
			
			if (spaceship.x < 30) {
				spaceship.x = 30
			}
			
			if (spaceship.x > 610) {
				spaceship.x = 610
			}
			
			if (isFiring) {
				bullet.y -= BULLET_SPEED;
				if (bullet.y < 0) {
					removeChild(bullet);
					bullet = null;
					isFiring = false;
				}
			}
			
			if (enemyToRemove >= 0) {
				enemyVector.splice(enemyToRemove, 1);
				enemyToRemove = -1;
				
				if (enemyVector.length == 0) {
					level++;
					playLevel();
				}
			}
			
			enemyVector.forEach(manageEnemy);
		}
		
		private function onMouseClck(e:MouseEvent):void {
			if (!isFiring) {
				fireBullet();
				isFiring = true;
			}
		}
		
		private function fireBullet():void {
			bullet = new bullet_mc;
			addChild(bullet);
			bullet.x = spaceship.x;
			bullet.y = 455;

			var glow:GlowFilter = new GlowFilter(0xFF0000, 1, 8, 8, 2, 2);
			bullet.filters =  new Array(glow);
		}
		
		private function setEnemy(enemy_level:uint):void {
			enemy = new enemy_mc();
			
			enemy.level.text = enemy_level.toString();
			
			enemy.killed = false;
			enemy.x = Math.random() * 500 + 70;
			enemy.y = Math.random() * 200 + 50;
		
			var glow:GlowFilter = new GlowFilter(0xFF00FF, 1, 8, 8, 2, 2);
			enemy.filters =  new Array(glow);
			
			addChild(enemy);
			
			var dir:Number = Math.random() * Math.PI * 2;
			enemy.xspeed = enemy_level * Math.cos(dir);
			enemy.yspeed = enemy_level * Math.sin(dir);
			enemyVector.push(enemy);
		}
		
		private function manageEnemy(curEnemy:enemy_mc, index:int, vector:Vector.<enemy_mc>):void {
			
			if (!curEnemy.killed) {
				
				curEnemy.x += curEnemy.xspeed;
				curEnemy.y += curEnemy.yspeed;
				
				if (curEnemy.x < 25) {
					curEnemy.x = 25
					curEnemy.xspeed *= -1;
				}
	
				if (curEnemy.x > 615) {
					curEnemy.x = 615
					curEnemy.xspeed *= -1;
				}
	
				if (curEnemy.y < 25) {
					curEnemy.y = 25
					curEnemy.yspeed *= -1;
				}
	
				if (curEnemy.y > 470) {
					curEnemy.y = 470
					curEnemy.yspeed *= -1;
				}
	
				// check if enemy collided with spaceship
				if (distance(spaceship, curEnemy) < 525) {
					die();
				}
				
				// check if bullet collided with enemy
				if (isFiring) {
					if (distance(bullet, curEnemy) < 841) {
						killEnemy(curEnemy);
					}
				}
			} else {
				curEnemy.width++;
				curEnemy.height++;
				curEnemy.alpha -= 0.01;
				if (curEnemy.alpha <= 0) {
					removeChild(curEnemy);
					curEnemy = null;
					enemyToRemove = index;
				}
			}
		}
		
		// checking distance between objects using pythagorean theorem
		private function distance(frm:Sprite, to:Sprite):Number {
			var distX:Number = frm.x - to.x;
			var distY:Number = frm.y - to.y;
			return (distX * distX) + (distY * distY);
		}
		
		// die
		private function die():void {
			var glow:GlowFilter = new GlowFilter(0x33CCFF, 1, 10, 10, 6, 6);
			spaceship.filters = new Array(glow);
			removeEventListener(Event.ENTER_FRAME, onEnterFrm);
			stage.removeEventListener(MouseEvent.CLICK, onMouseClck);
			
			scoreboard_mc.info.text = ".::  GAME OVER  ::.\n";
		
			trace ("your Score: " + score);
			sharedHighScore = SharedObject.getLocal('highScore');
			trace ("Current High Score: " + sharedHighScore.data.score);
			
			if (score > sharedHighScore.data.score) {
				sharedHighScore.data.score = score.toString();
				sharedHighScore.data.level = level.toString();
				scoreboard_mc.info.text += "\n*** CONGRATS!! ***\n";
				scoreboard_mc.info.text += "NEW\n";
				scoreboard_mc.info.text += "HIGH-SCHORE\n";
				scoreboard_mc.info.text += "BY\n";
				scoreboard_mc.info.text += "NEW USER\n";
				scoreboard_mc.info.text += sharedHighScore.data.score + "\n\n";
				scoreboard_mc.info.text += "LEVEL :::  " + sharedHighScore.data.level;
			} else {
				scoreboard_mc.info.text += "\n YOUR SCORE: \n";
				scoreboard_mc.info.text += score.toString() + "\n";
				scoreboard_mc.info.text += "-----------------\n";
				scoreboard_mc.info.text += "HIGH-SCHORE\n";	
				scoreboard_mc.info.text += "BY\n";
				scoreboard_mc.info.text += sharedHighScore.data.name +"\n";
				scoreboard_mc.info.text += sharedHighScore.data.score + "\n\n";
				scoreboard_mc.info.text += "LEVEL :::  " + sharedHighScore.data.level;
			}
			sharedHighScore.close();
		}
		
		// kill enemy
		private function killEnemy(theEnemy:enemy_mc):void {
			var glow:GlowFilter = new GlowFilter(0xFF00FF, 1, 10, 10, 6, 6);
			theEnemy.filters = new Array(glow);
			theEnemy.killed = true;
			removeChild(bullet);
			bullet = null;
			isFiring = false;
			
			score += int(theEnemy.level.text) * (4 - Math.floor(theEnemy.y/100));
			updateBoard();
		}	
	}
}