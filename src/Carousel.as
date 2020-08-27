package src
{
	import src.CarouselView;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.net.URLRequest;
	import src.items.*;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.events.*;
	import flash.utils.setTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import flash.media.Sound;
	import flash.media.SoundMixer;
	
	import org.osflash.signals.Signal;
	
	public class Carousel extends MovieClip
	{
		private var _data:Array;
		private var _parent:src.CarouselView;
		private var _animationNotches:int = 1;
		
		private var _selectedIndex:int = 0;
		private var _items:Dictionary = new Dictionary();
		
		private var _timer:Timer = new Timer(src.CarouselView.ANIMATION_SPEED * 2 * 1000);
		
		public var started:Boolean;
		
		public static const CAROUSEL_X = 960;
		public static const CAROUSEL_Y = 540;
		public static const CAROUSEL_LENGTH = 7;
		
		public var selected:Signal = new Signal(int);
		
		public function Carousel(parent:DisplayObjectContainer, data:Array)
		{
			super();
			_parent = parent as src.CarouselView;
			parent.addChild(this);
			_data = data;
			
			_update();
		}
			
		/**
		 * Compute the absolute index using the position relative to the selected index
		 * @param position	the position relative to the selected index (can be negative)
		 * @return the index resulting from the computation
		 */
		private function _computeIndex(position:int):int
		{
			return (_data.length + _selectedIndex + position) % _data.length;
		}
		
		/**
		 * Initialize the carousel
		 * @return void
		 */
		private function _update():void
		{
			//reset the carousel to its initial values and rebuild the items
			this.removeChildren();
			_items = new Dictionary();
			this.x = CAROUSEL_X;
			this.y = CAROUSEL_Y;
			
			//add items
			for (var i:int = -CAROUSEL_LENGTH; i <= CAROUSEL_LENGTH; i++)
			{
				_addItem(i);
			}
		
		}
		
		/**
		 * Add an item to the carousel at the requested position
		 * @param position		the position relative to the selected item
		 * @return void
		 */
		private function _addItem(position:int):void
		{
			var index:int = _computeIndex(position);
			var item:BaseItem = _createItemInstance(index);
			
			item.x = BaseItem.ITEM_WIDTH * position;
			item.y = 0;
			
			var dropShadow = src.CarouselView.createDropShadow();
			item.filters = new Array(dropShadow);
			
			//If the item is the one selected, make it larger
			if (index == _selectedIndex)
			{
				item.scaleX = 1.2;
				item.scaleY = 1.2;
			}
			
			//Add button mode for visible items
			if (Math.abs(position) <= 3)
			{
				item.buttonMode = true;
				item.addEventListener(MouseEvent.CLICK, _onItemClicked(position));
				item.addEventListener(MouseEvent.MOUSE_OVER, _onItemHovered(position));
				item.addEventListener(MouseEvent.MOUSE_OUT, _onItemUnhovered(position));
			}
			
			//Add the item created to the dictionnary
			_items[index] = item;
		
		}
		
		/**
		 * When an item is clicked, move the carousel to its position
		 * @param position		the position relative to the selected item
		 * @return Function
		 */
		private function _onItemClicked(position:int):Function
		{
			var carousel = this;
			return function(e:MouseEvent):void
			{
				carousel.moveBy(position)
			};
		}
		
		/**
		 * When an item is hovered, make it larger
		 * @param position		the position relative to the selected item
		 * @return Function
		 */
		private function _onItemHovered(position:int):Function
		{
			var carousel = this;
			return function(e:MouseEvent):void
			{
				var index:int = _computeIndex(position);
				var item:BaseItem = _items[index];
				
				TweenMax.to(item, src.CarouselView.ANIMATION_SPEED, {scaleX: 1.2, scaleY: 1.2});
			};
		}
		
		/**
		 * When an item is unhovered, make it smaller
		 * @param position		the position relative to the selected item
		 * @return Function
		 */
		private function _onItemUnhovered(position:int):Function
		{
			var carousel = this;
			return function(e:MouseEvent):void
			{
				var index:int = _computeIndex(position);
				var item:BaseItem = _items[index];
				
				if (index != _selectedIndex)
				{
					TweenMax.to(item, src.CarouselView.ANIMATION_SPEED, {scaleX: 1, scaleY: 1});
				}
			};
		}
		
		/**
		 * Create an item instance with the correct class
		 * @param index	the index of the item in the data array
		 * @return an item
		 */
		private function _createItemInstance(index:int):BaseItem
		{
			var data:Object = _data[index];
			var testItemClassName:String = "src.items.Item_" + data['index'];
			var testItemClass:Class = getDefinitionByName(testItemClassName) as Class;
			
			return new testItemClass(this, data);
		}
		
		/**
		 * When the carousel is animated
		 * @param e
		 * @return void
		 */
		private function _onMove(e:TimerEvent):void
		{
			moveBy(_animationNotches);
		}
		
		/**
		 * Move the carousel to the requested position
		 * @param position	the position to move the carousel (can be negative)
		 * @return an item
		 */
		public function moveBy(position:int):void
		{
			//Wait for the completion of the translation before launching another one
			if (!TweenMax.isTweening(this))
			{
				//Reduce the scale of the former selected item
				TweenMax.to(_items[_selectedIndex], src.CarouselView.ANIMATION_SPEED * Math.abs(position), {scaleX: 1, scaleY: 1});
				
				//Increase the scale of the new selected item
				selectIndex(_computeIndex(position));
				var item:BaseItem = _items[_selectedIndex];
				TweenMax.to(item, src.CarouselView.ANIMATION_SPEED * Math.abs(position), {scaleX: 1.2, scaleY: 1.2});
				item.animate();
				
				//Move carousel
				var translation = this.x + BaseItem.ITEM_WIDTH * position * -1;
				TweenMax.to(this, src.CarouselView.ANIMATION_SPEED * Math.abs(position), {x: translation, onComplete: _update});
			}
		}
		
		/**
		 * Select an item
		 * @param index	the index of the item to select
		 * @return void
		 */
		public function selectIndex(index:int):void
		{
			_selectedIndex = index;
			
			selected.dispatch(index);
		
		}
		
		/**
		 * Launch the carousel animation
		 * @param started
		 * @return void
		 */
		public function animate(started:Boolean):void
		{
			var sound:Sound;
			started = started;
			if (started === true)
			{
				SoundMixer.stopAll();
				sound = new Sound(new URLRequest("res/audio/Jungle_Atmosphere_Afternoon.mp3"));
				sound.play();
				
				_timer.addEventListener(TimerEvent.TIMER, _onMove);
				_timer.start();
			}
			else if (started === false)
			{
				SoundMixer.stopAll();
				
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, _onMove);
			}
		}
		
		/**
		 * Set the number of notches in order to move the carousel
		 * @param notches
		 * @return void
		 */
		public function setAnimationNotches(notches:int):void
		{
			_animationNotches = notches;
		}
	
	}

}