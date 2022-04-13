#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import <objc/runtime.h>

#import "Path.h"
#import "Win.h"
#import "MTLUtils.h"
#import "Plane.h"
#import "MetalBaseLayer.h"
#import "MetalTextureLayer.h"

class App {
  
  private:
  
    inline static const int STAGE_WIDTH = 1280;
    inline static const int STAGE_HEIGHT = 720;
    inline static const float FPS = 30.0;
  
    dispatch_source_t _timer;

    Win *_win;
    NSView *_view;
    MetalTextureLayer<Plane> *_layer;
    unsigned int *_texture;

  public:
  
    App() {
            
      this->_texture = new unsigned int[STAGE_WIDTH*STAGE_HEIGHT];
      
      this->_win = new Win(STAGE_WIDTH,STAGE_HEIGHT);
      this->_layer = new MetalTextureLayer<Plane>();
      
      for(int i=0; i<App::STAGE_HEIGHT; i++) {
        for(int j=0; j<App::STAGE_WIDTH; j++) {
          this->_texture[i*this->STAGE_WIDTH+j] = 0xFF000000|random()%0xFFFFFF;
        }
      }
      
      if(this->_layer->init(STAGE_WIDTH,STAGE_HEIGHT,@"nearest-macosx.metallib",nil,false)) {
        
        this->_view = [[NSView alloc] initWithFrame:CGRectMake(0,0,STAGE_WIDTH,STAGE_HEIGHT)];
        this->_view.layer = this->_layer->layer();
        this->_win->addChild(this->_view);
      
        this->_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,dispatch_queue_create("ENTER_FRAME",0));
        dispatch_source_set_timer(this->_timer,dispatch_time(0,0),(1.0/App::FPS)*1000000000,0);
        dispatch_source_set_event_handler(this->_timer,^{
        
          this->_layer->replace(this->_texture);
          
          this->_layer->update(^(id<MTLCommandBuffer> commandBuffer){
            this->_layer->cleanup();
          });
            
        });
        if(this->_timer) dispatch_resume(this->_timer);
          
      }
    }
  
    ~App() {
      
      if(this->_timer){
        dispatch_source_cancel(this->_timer);
        this->_timer = nullptr;
      }
      
      delete this->_win;
      delete[] this->_texture;
    }
  
};

#pragma mark AppDelegate
@interface AppDelegate:NSObject <NSApplicationDelegate> {
    App *app;
}
@end
@implementation AppDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    app = new App();
}
-(void)applicationWillTerminate:(NSNotification *)aNotification {
    delete app;
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        srand(CFAbsoluteTimeGetCurrent());
        srandom(CFAbsoluteTimeGetCurrent());
        id app = [NSApplication sharedApplication];
        id delegat = [AppDelegate alloc];
        [app setDelegate:delegat];
        [app run];
    }
}
@end