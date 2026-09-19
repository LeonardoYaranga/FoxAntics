# TileMapLayer
Permite usar una textura para poder construir un nivel, usualmente estas texturas tienen una medida en x,y de pixeles. En este caso esa medida es de  18x18 y hay que respetarla en el TileSize del TileSet en el Inspector para que se descuadre con la resolucion de pantalla que quiza ya configuramos. Hay algunas herramientas para ir creando el mapa, podemos seleccionar los bloques que se requiera e ir creando el nivel. Es interesante la herramienta de dado (Place random tile) con Scattering que cuando eliges varios tiles los mezcla y crea una estructura randomica e incompleta segun el Scattering.![[TileMapGeneral.png]]
Se puede agregar en el aparatado de TileSet, se los llama Atlas y cada cuadro se identifica por las coordenadas.![[AddTileSet.png]]

## Patterns
Podemos seleccionnar que grupo de tiles que hemos formado en la pantalla se convierta en un "Pattern". Solo hay que arrastrar a la ventana "Patterns" en TileMap para que se quede guardado y poder reusarlo.
![[Patterns.png]]
## Terrain sets
Los **Terrain sets** (o Terrenos) nos permiten configurar "Autotiling", es decir, crear reglas para que los tiles se conecten y acoplen automáticamente al dibujarlos. Existen 3 modos para detectar cómo se conectan los vecinos: **Match Corners and Sides**, **Match Corners** y **Match Sides**.

![[InspectorTerrainSets.png]]

**1. Match Corners and Sides (Esquinas y Lados):**
Se usa cuando nos importa qué hay tanto en los lados como en las diagonales del tile. Al configurarlo, Godot nos permite pintar las conexiones en forma de cuadritos cubriendo todo el tile.
Para el césped se usó este modo porque queremos que todo el bloque de tierra y pasto se mezcle y acomode de forma natural, reconociendo bordes y esquinas. 
![[TerrainGreenGrassPainting.png]]

**2. Match Sides (Solo Lados):**
Se usa cuando **solo** nos importa qué hay arriba, abajo, a la izquierda o a la derecha (ignorando las diagonales). Por eso, al configurarlo, ya no salen cuadritos, sino unos **triángulos o diamantes** que apuntan hacia los bordes. Esa forma extraña es la manera gráfica de Godot de decir "esta conexión solo va hacia este lado en específico".
Lo usamos en las "Pipes" (tuberías) seleccionando **Match Sides** porque una tubería solo se conecta de forma recta con otra, sin importarle qué hay en la esquina.
![[TerrainPipes.png]]

Finalmente, para usar lo configurado, vamos a la pestaña de TileMap en la parte inferior, entramos al apartado de **Terrains**, y ya podemos pintar nuestros terrenos automáticos con herramientas como el Paint Tool y Rect Tool.
![[PuttingPipesAndGreenGrassOnTileMapTerrains.png]]
## TileSet Animation
Esto se puede realizar en el apartado de TileSet/Select. Se puede escoger a un tile para hacerlo animacion, pero se debe borrar los otros tiles que seran parte de la animacion. Al tile que sera el primer frame de la animacion se le modifica las propiedades Animation/Columms a 1, la velocidad al gusto y en los Frames se agrega el numero de frames que tiene, en este caso son 2 adicionales al que ya se tiene default. En el apartado grafico se ve como el primer frame es el que se esta manipulando porque esta mas remarcado de un verde y los siguientes hacia abajo con de un verde mas suave.
![[ConfiguringTileWaterAnimationFramesAndColumns.png]]
Luego se puede colocar en el apartado TileMap con las herramientas de creacion.
![[PuttingWaterTileAnimated.png|491]]

Para un tile que su frame esta a la derecha y no abajo se hace el proceso pero colocando en Animation/Collumns = 2 
![[ConfiguringTileRiverAnimationFramesAndColumns.png]]
En este caso se realiza para cada tile que conformaria el rio en primera intancia con su frame consiguiente agregado.

## Physics Layers
Los TileMapLauer en su propiedad TileSet tienen la propiedad de PhysicsLayer que es lo que se configura para que puedan no dejar caer al player al infinito, se debe crear un layer en el inspector y en la ventana de TileSet en Paint se puede pintar el area que colisionara. Como el Mapa no necesita que nadie mas lo detecte y el solo debe ser detectado por el player se coloca en el inspecto CollisionLayer 1 porq la 1 es de platform y en mask no esta ninguna.

![[TilesetPaintPaintPropertiesPhisics.png]]
### One way collision
Se puede activar en el apartado de TileSet/Paint/Physics/Oneway

# Player
## Collision 2D
En la propiedad Collision que tiene un player: CharacterBody2D
la manera de entender es que Layer es lo que es dicho objeto, osea si tengo el player ahi, y la capa 2 es player_body entc se seleciona y lo de mask es con que puedo interactura, colisionar, en este caso la layer "platform" seria detectada por  la "player_body".
![[ProjectSettingLayerNames2DPhysics.png|292]]
![[CollisionObject2DCollisionLayerAndMask.png]]

## Camera2D
Se puede crear una Camera2D dentro de la escena del jugador, asi esta seguira al jugador.
Ademas se puede limitar segun se requiera hasta donde puede grabar la camara. Eso se obtiene del nivel, en este caso 648aprox en y y 0 en x.
![[BoundariesOfLevelBase.png|194]]
Esas medidas se establecen en la limitacion de la camara.
![[Camera2DLimits.png]]
Y de esa manera la camara no permite visualizar lo que esta fuera de esas medidas.

![[ViewOfTheMapLimitedByCameraLimits.png]]
Sin embargo tbn se puede configurar por codigo en el script del player para hacerlo menos estatico.
![[playercamLimitsStarted.png]]
## Animation Player & Animation Tree
Para poder controlar las animaciones del player y su transicion, se crea esta dupla, las animaciones con las keys de los sprites correspondientes del nodod Sprite2D se crea en el AnimationPlayer, luego en el  AnimationTree con Tree Root de AnimationNodeStateMachine se le agrega y une las animaciones, colocando que su transicion entre ellas dependa de una variable que este en el script del Player, en este caso is_still que indica si la velocidad es casi 0 en x en ese caso pasa a idel y sino pasa a run.![[AnimationTreeWithIdleAndRunAnimsConfigured.png]]


# Enemies
## Raycast2D
Es un nodo que no puede ser chocado (No tiene Collision Layer) pero si puede chocar a otros nodos(Tiene Collision Mask). Sirve para detectar otros nodos.
Para este caso se usara Raycast2D para saber cuando se collisiona con paredes o el piso y de esa manera saber cuando cambiar el trayecto de los enemigos, asi estos no se caeran o quedaran pegados en la paredes.
## Eliminated
Al eliminar a un enemigo y se ejecute funciones donde muestre la animacion de morir, es mejor si desactiva su area de "hit" y detiene su movimiento. Se debe hacer de manera diferida para evitar problemas: "set_physics_process.call_deferred(false)
	hit_coll_shape.call_deferred("set_disabled",true)"

# Inheritance
Se puede crear una escena Enemy_Base de la cual hereden los demas enemigos para generalizar aspectos como el movimiento, ejecucion de animaciones, entre otros aspectos. Cada enemigo hijo puede implementar sus figuras de colision ajustadas a su sprite y puede sobreescribir funciones si quiere modificar su comportamiento en cierto aspecto.