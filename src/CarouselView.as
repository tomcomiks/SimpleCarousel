package src
{
	/**
		A looping carousel of 15 item classes showing 7 items at a time.
	    There are buttons to animate in/out and control the carousel.
	    The Carousel can animate left and right.
	    The Selected index is obvious.
	    Items marked with animation level 1 or greater have unique animations and audio events on selection.
	 */
	
	import com.greensock.TimelineMax;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.*;
	import src.Carousel;
	import src.items.*;
	
	public class CarouselView extends MovieClip
	{
		private var _carousel:Carousel;
		private var _leftArrow_mc:SimpleButton;
		private var _rightArrow_mc:SimpleButton;
		private var _animIn_mc:SimpleButton;
		private var _animOut_mc:SimpleButton;
		
		public static const ANIMATION_SPEED = 0.6;
		
		public static const DATA:Array = [
			{index: 0, title: "Title 0"},
			{index: 1, title: "Title 1"},
			{index: 2, title: "Title 2"},
			{index: 3, title: "Title 3", animation : 1},
			{index: 4, title: "Title 4"},
			{index: 5, title: "Title 5"},
			{index: 6, title: "Title 6"},
			{index: 7, title: "Title 7", animation: 2},
			{index: 8, title: "Title 8"},
			{index: 9, title: "Title 9"},
			{index: 10, title: "Title 10"},
			{index: 11, title: "Title 11", animation: 3},
			{index: 12, title: "Title 12"},
			{index: 13, title: "Title 13"},
			{index: 14, title: "Title 14"},
			{index: 15, title: "Title 15", animation: 2},
		];	
		
				
		/**
		 * Create a rectangle
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param color
		 * @return Shape
		 */
		public static function createRectangle(x:Number, y:Number, width:Number, height:Number, color:uint):Shape
		{
			var rectangle:Shape = new Shape();
			rectangle.graphics.clear();
			rectangle.graphics.beginFill(color);
			rectangle.graphics.drawRect(x, y, width, height);
			rectangle.graphics.endFill();
			
			return rectangle;
		}
		
		/**
		 * Create a text field
		 * @param text
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param color
		 * @return TextField
		 */
		public static function createTextField(text:String, x:Number, y:Number, width:Number, height:Number, color:uint):TextField
		{
			var robotoFont = new Roboto();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = height;
			textFormat.font = robotoFont.fontName;
			textFormat.color = color;
			textFormat.align = TextFormatAlign.CENTER;
			
			var textField:TextField = new TextField();
			textField.x = x;
			textField.y = y;
			textField.width = width;
			textField.defaultTextFormat = textFormat;
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.CENTER;
			
			textField.text = text;
			
			return textField;
		}
		
		/**
		 * Create a shadow
		 * @param text
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param color
		 * @return DropShadowFilter
		 */
		public static function createDropShadow():DropShadowFilter
		{
			var dropShadow:DropShadowFilter = new DropShadowFilter();
			dropShadow.distance = 0;
			dropShadow.angle = 45;
			dropShadow.color = 0x333333;
			dropShadow.alpha = 1;
			dropShadow.blurX = 10;
			dropShadow.blurY = 10;
			dropShadow.strength = 1;
			dropShadow.quality = 15;
			dropShadow.inner = false;
			dropShadow.knockout = false;
			dropShadow.hideObject = false;
			return dropShadow;
		}
			
		/**
		 * Add controls to the stage
		 * @return void
		 */
		private function _addUIElements():void
		{
			var dropShadow = CarouselView.createDropShadow();
			
			//Buttons container
			var buttons:MovieClip = new MovieClip();
			buttons.x = Carousel.CAROUSEL_X;
			buttons.y = Carousel.CAROUSEL_Y - 300;
			this.addChild(buttons);
			
			//Left arrow	
			_leftArrow_mc = new LeftArrow_mc();
			_leftArrow_mc.x = -300;
			_leftArrow_mc.filters = new Array(dropShadow);
			_leftArrow_mc.addEventListener(MouseEvent.CLICK, _leftArrowClicked);
			buttons.addChild(_leftArrow_mc);
			
			//Right arrow	
			_rightArrow_mc = new RightArrow_mc();
			_rightArrow_mc.x = 300;
			_rightArrow_mc.filters = new Array(dropShadow);
			_rightArrow_mc.addEventListener(MouseEvent.CLICK, _rightArrowClicked);
			buttons.addChild(_rightArrow_mc);
			
			//Play
			_animIn_mc = new AnimIn_mc();
			_animIn_mc.x = -100;
			_animIn_mc.filters = new Array(dropShadow);
			_animIn_mc.addEventListener(MouseEvent.CLICK, _animInClicked);
			buttons.addChild(_animIn_mc);
			
			//Stop
			_animOut_mc = new AnimOut_mc();
			_animOut_mc.x = 100;
			_animOut_mc.filters = new Array(dropShadow);
			_animOut_mc.addEventListener(MouseEvent.CLICK, _animOutClicked);
			buttons.addChild(_animOut_mc);
		}
			
		/**
		 * Trace the index selected
		 * @param index
		 * @return void
		 */
		private function _onItemSelected(index:int):void
		{
			trace('Current index is ' + index);
		}
		
		/**
		 * When the start button is clicked
		 * @param e
		 * @return void
		 */
		private function _animInClicked(e:MouseEvent):void
		{
			_carousel.animate(true);
		}
		
		/**
		 * When the stop button is clicked
		 * @param e
		 * @return void
		 */
		private function _animOutClicked(e:MouseEvent):void
		{
			_carousel.animate(false);
		}
		
		/**
		 * When the left arrow button is clicked
		 * @param e
		 * @return void
		 */
		private function _leftArrowClicked(e:MouseEvent):void
		{
			_carousel.setAnimationNotches(-1);
			_carousel.moveBy(-1);
		}
		
		/**
		 * When the right arrow button is clicked[Embed(source="Animation.swf", symbol="UI_TA_TEST")][Embed(source="Animation.swf", symbol="UI_TA_TEST")][Embed(source="Animation.swf", symbol="UI_TA_TEST")]
		 * @param e
		 * @return void
		 */
		private function _rightArrowClicked(e:MouseEvent):void
		{
			_carousel.setAnimationNotches(1);
			_carousel.moveBy(1);
		}
		
		/**
		 * Main function
		 * @return void
		 */
		public function CarouselView():void
		{
			//Carousel to be coded 
			_carousel = new Carousel(this, DATA);
			
			_addUIElements();
			
			//Trace selected item with Signals
			_carousel.selected.add(_onItemSelected);
		
		}
	
	}

}
