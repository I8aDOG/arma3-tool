# Vs. Tricky (trickster, what ever)

ok ok so heres the build instructions.

first, default kade engine build obv. [here if you don't know](https://kadedev.github.io/Kade-Engine/building)

next, we gotta do some video shit or what ever.

just do these things in the cmd window:

```
haxelib install actuate
haxelib git extension-webm https://github.com/KadeDev/extension-webm
lime rebuild extension-webm windows
```
you can change windows to mac or linux

alright you got everything you need to build now.

just do like

```
lime test windows -release
```

or what ever platform, be it linux or mac or smth lol!


btw special thanks to [GWebDev](https://github.com/GrowtopiaFli) for obviously video support, chad man.
removes pause between kill animation when you lose and fixes expurgation score display.
