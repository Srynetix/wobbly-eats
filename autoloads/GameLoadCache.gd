extends SxLoadCache

func load_resources() -> void:
    store_scene("Destination", "res://objects/Terrain/Destination.tscn")
    store_scene("Destination", "res://objects/Terrain/Destination.tscn")
    store_resource("PackageTexture", "res://objects/Package/Package.png")
    store_resource("Font", "res://thirdparty/fonts/VTF MisterPixel/Mister Pixel Regular.otf")

    store_scene("BootScreen", "res://screens/BootScreen/BootScreen.tscn")
    store_scene("GameScreen", "res://screens/GameScreen/GameScreen.tscn")
    store_scene("IntroScreen", "res://screens/IntroScreen/IntroScreen.tscn")
    store_scene("TitleScreen", "res://screens/TitleScreen/TitleScreen.tscn")
    store_scene("EndScreen", "res://screens/EndScreen/EndScreen.tscn")
