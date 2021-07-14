package states;

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
import states.GameState;

class StartGame extends State {

    public function new(){
        super();
    }
    override function load(resources:Resources) {
        var atlas=new JoinAtlas(700,700);
        atlas.add(new FontLoader("Kenney_Thick",20));
        atlas.add(new ImageLoader("quake"));
        resources.add(atlas);
    }

    override function init() {
        this.stageColor(50,0,0);
        var image=new Sprite("quake");
        image.smooth=false;
        image.x=  Screen.getWidth()*0.25;
        image.y=Screen.getHeight()*0.1;
        stage.addChild(image);
        
		var title=new Text("Kenney_Thick");
        title.smooth=false;
        title.x = Screen.getWidth()*0.28;
        title.y = Screen.getHeight()*0.8;
        title.text="Press the spcacebar to start";
        title.set_color(Color.Black);
        var subTitle=new Text("Kenney_Thick");
        subTitle.smooth=false;
        subTitle.x = Screen.getWidth()*0.38;
        subTitle.y = Screen.getHeight()*0.9;
        subTitle.text="Be carefull";
		subTitle.set_color(Color.Black);
        stage.addChild(subTitle);
		stage.addChild(title);
       
    }
    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
           this.changeState(new GameState(1));
        }
    }
}