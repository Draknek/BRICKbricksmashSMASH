OUTPUT := game.swf

ifdef DEBUG
DEBUG_FLAG := true
else
DEBUG_FLAG := false
endif

all:
	fcsh-wrap -optimize=true -output $(OUTPUT) -static-link-runtime-shared-libraries=true -compatibility-version=3.0.0 --target-player=10.1.0 -compiler.debug=$(DEBUG_FLAG) Preloader.as -frames.frame mainframe Main

android: all
	cd air && mkapk app-android.xml bricksmash.apk

clean:
	rm -f *~ $(OUTPUT) .FW.*

.PHONY: all clean


