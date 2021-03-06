package states;

import com.soundLib.SoundManager;
import com.loading.basicResources.SoundLoader;
import kha.Color;
import com.gEngine.display.Sprite;
import com.loading.basicResources.ImageLoader;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.gEngine.helpers.Screen;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;

class EndGame extends State {
    var level:Int;
    var win:Bool;
    public function new(level:Int, win:Bool = false){
        this.level=level;
        this.win = win;
        super();
    }
    override function load(resources:Resources) {
        var atlas=new JoinAtlas(1000,1000);
        atlas.add(new FontLoader("Kenney_Thick",20));
        atlas.add(new ImageLoader("game_over"));
        atlas.add(new ImageLoader("win"));
        resources.add(atlas);
        resources.add(new SoundLoader("WinSong", false));
        resources.add(new SoundLoader("endGame", false));
    }

    override function init() {
        if (!win){
            this.stageColor(50,0,0);
            var image=new Sprite("game_over");
            image.smooth=false;
            image.x= Screen.getWidth()*0.35;
            image.y= Screen.getHeight()*0.1;
            stage.addChild(image);    
            SoundManager.playMusic("endGame",false);
        }else{
            this.stageColor(47,242,190);
            var image=new Sprite("win");
            image.smooth=false;
            image.x=  Screen.getWidth()*0.35;
            image.y=Screen.getHeight()*0.1;
            stage.addChild(image);    
            SoundManager.playMusic("WinSong");
        }
        
        

        var scoreText=new Text("Kenney_Thick");
        scoreText.smooth=false;
        scoreText.x = Screen.getWidth()*0.38;
        scoreText.y = Screen.getHeight()*0.7;
        scoreText.text="Final Score "+level;
        scoreText.set_color(Color.Black);

        var title=new Text("Kenney_Thick");
        title.smooth=false;
        title.x = Screen.getWidth()*0.32;
        title.y = Screen.getHeight()*0.75;
        title.text="Spcacebar - Play again";
        title.set_color(Color.Black);
        var subTitle=new Text("Kenney_Thick");
        subTitle.smooth=false;
        subTitle.x = Screen.getWidth()*0.38;
        subTitle.y = Screen.getHeight()*0.8;
        subTitle.text="M - Main Menu";
		subTitle.set_color(Color.Black);

        stage.addChild(scoreText);
        stage.addChild(subTitle);
		stage.addChild(title);
       
    }
    override function update(dt:Float) {
        super.update(dt);
        if(level==4){
            level--;
        }
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
           this.changeState(new GameState(this.level));
        }
        if(Input.i.isKeyCodePressed(KeyCode.M)){
            this.changeState(new StartGame());
         }
    }
}