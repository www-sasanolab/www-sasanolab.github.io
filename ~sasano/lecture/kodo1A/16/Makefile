file=sample1
$(file).scr: $(file).c
	gcc -std=c99 $(file).c -o $(file).scr -lscrnsave -lgdi32 -lopengl32
s:
	$(file).scr /s
