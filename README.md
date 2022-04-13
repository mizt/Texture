#### Build shader

```
filename=nearest.metal; xcrun -sdk macosx metal -c $filename -o ${filename%.*}-macosx.air; xcrun -sdk macosx metallib ${filename%.*}-macosx.air -o ${filename%.*}-macosx.metallib; rm ./*.air
```

#### Build

```
clang++ -std=c++17 -Wc++17-extensions -fobjc-arc -O3 -framework Cocoa -framework Metal -framework QuartzCore ./main.mm -o ./main
```

