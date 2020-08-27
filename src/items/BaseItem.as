package src.items
{
	import com.greensock.TimelineMax;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import src.CarouselView;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class BaseItem extends MovieClip
	{
		protected var _data:Object;
		protected var _parent:DisplayObjectContainer;
		
		public static const ITEM_WIDTH = 240;
		public static const ITEM_HEIGHT = 200;
		
		public function BaseItem(parent:DisplayObjectContainer, data:Object)
		{
			super();
			_data = data;
			_parent = parent;
			
			_init();
		}
			
		/**
		 * Initialize the item card
		 * @return void
		 */
		private function _init()
		{
			var card:Shape = src.CarouselView.createRectangle(-this.width / 2, this.height / 2, this.width, this.height, 0xffffff);
			this.addChild(card);
			
			//Add a label below the image
			var label:TextField = src.CarouselView.createTextField(_data['title'], -this.width / 2, this.height / 2 - 70, this.width, 20, 0x000000);
			this.addChild(label);
			
			_parent.addChild(this);
		}
		
		/**
		 * Animate the item
		 * @return void
		 */
		public function animate():void
		{
			var animation:TimelineMax = new TimelineMax();
			var sound:Sound;
			
			switch (_data['animation'])
			{
			case 1: 
				animation.to(this, src.CarouselView.ANIMATION_SPEED * 0.5, {scaleX: 2, scaleY: 2}).to(this, src.CarouselView.ANIMATION_SPEED * 0.5, {scaleX: 1.2, scaleY: 1.2});
				
				SoundMixer.stopAll();
				sound = new Sound(new URLRequest("res/audio/Dog_Barking.mp3"));
				sound.play();
				break;
			case 2: 
				animation.to(this, src.CarouselView.ANIMATION_SPEED * 0.5, {tint: 0x66ccff}).to(this, src.CarouselView.ANIMATION_SPEED * 0.5, {tint: null});
				
				SoundMixer.stopAll();
				sound = new Sound(new URLRequest("res/audio/Flies_Buzzing_and_Circling.mp3"));
				sound.play();
				
				break;
			case 3: 
				animation.to(this, src.CarouselView.ANIMATION_SPEED * 1, {rotation: 360});
				
				SoundMixer.stopAll();
				sound = new Sound(new URLRequest("res/audio/Woodpecker_Pecking_on_Tree.mp3"));
				sound.play();
				break;
			default:
				
				break;
			}
		}
	
	}

}