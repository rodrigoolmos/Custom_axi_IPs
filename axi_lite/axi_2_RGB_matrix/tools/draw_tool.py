import tkinter as tk
from tkinter import filedialog

class DrawingApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Dibujo en RGB")

        # Variables
        self.canvas_size = 640  # Tamaño del canvas (64x64 cuadrados de 10x10 píxeles)
        self.square_size = self.canvas_size // 64  # Tamaño de cada cuadrado
        self.current_color = "#ffffff"  # Color inicial blanco
        self.grid = [[0 for _ in range(64)] for _ in range(64)]  # Matriz para almacenar los colores
        self.brush_size = 1  # Tamaño inicial del pincel

        # Crear el canvas con fondo negro
        self.canvas = tk.Canvas(master, width=self.canvas_size, height=self.canvas_size, bg="black")
        self.canvas.pack()

        # Dibujar la cuadrícula
        self.draw_grid()

        # Menú para elegir color
        self.color_menu = tk.StringVar(master)
        self.color_menu.set("Blanco")  # Valor inicial

        colors = {
            "Rojo": "#ff0000",
            "Verde": "#00ff00",
            "Azul": "#0000ff",
            "Cian": "#00ffff",
            "Magenta": "#ff00ff",
            "Amarillo": "#ffff00",
            "Blanco": "#ffffff",
            "Negro": "#000000"
        }

        self.color_option_menu = tk.OptionMenu(master, self.color_menu, *colors.keys(), command=self.change_color)
        self.color_option_menu.pack()

        # Control deslizante para el tamaño del pincel
        self.brush_size_slider = tk.Scale(master, from_=1, to=10, orient=tk.HORIZONTAL, label="Tamaño del Pincel", command=self.change_brush_size)
        self.brush_size_slider.set(self.brush_size)  # Valor inicial del slider
        self.brush_size_slider.pack()

        # Entrada de texto
        self.text_entry = tk.Entry(master)
        self.text_entry.pack()

        # Botón para dibujar el texto
        self.text_button = tk.Button(master, text="Dibujar Texto", command=self.draw_text)
        self.text_button.pack()

        # Botón para guardar
        self.save_button = tk.Button(master, text="Guardar", command=self.save_image)
        self.save_button.pack()

        # Bind para dibujar con el pincel
        self.canvas.bind("<B1-Motion>", self.paint)

    def draw_grid(self):
        for i in range(64):
            for j in range(64):
                x1 = i * self.square_size
                y1 = j * self.square_size
                x2 = x1 + self.square_size
                y2 = y1 + self.square_size
                self.canvas.create_rectangle(x1, y1, x2, y2, outline="darkgrey")

    def change_color(self, color_name):
        colors = {
            "Rojo": "#ff0000",
            "Verde": "#00ff00",
            "Azul": "#0000ff",
            "Cian": "#00ffff",
            "Magenta": "#ff00ff",
            "Amarillo": "#ffff00",
            "Blanco": "#ffffff",
            "Negro": "#000000"
        }
        self.current_color = colors[color_name]

    def change_brush_size(self, size):
        self.brush_size = int(size)

    def paint(self, event):
        # Obtener la posición del mouse
        x, y = event.x, event.y
        
        # Calcular la cuadrícula correspondiente
        grid_x = x // self.square_size
        grid_y = y // self.square_size

        # Pintar el área correspondiente según el tamaño del pincel
        for i in range(self.brush_size):
            for j in range(self.brush_size):
                if grid_x + i < 64 and grid_y + j < 64:  # Asegurarse de no salir de los límites
                    self.canvas.create_rectangle(
                        (grid_x + i) * self.square_size, (grid_y + j) * self.square_size,
                        (grid_x + i + 1) * self.square_size, (grid_y + j + 1) * self.square_size,
                        fill=self.current_color, outline="")
                    # Actualizar la matriz de colores
                    self.update_grid(grid_x + i, grid_y + j)

    def update_grid(self, x, y):
        # Actualizar el color en la matriz
        color_to_value = {
            "#ff0000": 0x04,  # Rojo
            "#00ff00": 0x02,  # Verde
            "#0000ff": 0x01,  # Azul
            "#ffff00": 0x06,  # Amarillo (Rojo + Verde)
            "#00ffff": 0x03,  # Cian (Verde + Azul)
            "#ff00ff": 0x05,  # Magenta (Rojo + Azul)
            "#ffffff": 0x07,  # Blanco (Rojo + Verde + Azul)
            "#000000": 0x00   # Negro
        }
        if self.current_color in color_to_value:
            self.grid[y][x] = color_to_value[self.current_color]

    def draw_text(self):
        text = self.text_entry.get().upper()  # Convertir el texto a mayúsculas
        start_x, start_y = 0, 0  # Posición inicial donde dibujar

        for char in text:
            if start_x >= 64:
                start_x = 0
                start_y += 8  # Moverse a la siguiente fila de caracteres

            if start_y >= 64:
                break  # Si se sale del canvas, dejar de dibujar

            self.draw_character(char, start_x, start_y)
            start_x += 8  # Espacio horizontal entre caracteres

    def draw_character(self, char, start_x, start_y):
        # Fuente alfanumérica 5x7 con Ñ incluida
        font = {
            'A': ["  X  ", " X X ", "XXXXX", "X   X", "X   X"],
            'B': ["XXXX ", "X   X", "XXXX ", "X   X", "XXXX "],
            'C': [" XXXX", "X    ", "X    ", "X    ", " XXXX"],
            'D': ["XXXX ", "X   X", "X   X", "X   X", "XXXX "],
            'E': ["XXXXX", "X    ", "XXXX ", "X    ", "XXXXX"],
            'F': ["XXXXX", "X    ", "XXXX ", "X    ", "X    "],
            'G': [" XXXX", "X    ", "X  XX", "X   X", " XXXX"],
            'H': ["X   X", "X   X", "XXXXX", "X   X", "X   X"],
            'I': ["XXXXX", "  X  ", "  X  ", "  X  ", "XXXXX"],
            'J': ["  XXX", "   X ", "   X ", "X  X ", " XX  "],
            'K': ["X   X", "X  X ", "XXX  ", "X  X ", "X   X"],
            'L': ["X    ", "X    ", "X    ", "X    ", "XXXXX"],
            'M': ["X   X", "XX XX", "X X X", "X   X", "X   X"],
            'N': ["X   X", "XX  X", "X X X", "X  XX", "X   X"],
            'Ñ': [" XX  ", "X  X ", "XX X ", "X XX ", "X  X "],  # Letra Ñ
            'O': [" XXX ", "X   X", "X   X", "X   X", " XXX "],
            'P': ["XXXX ", "X   X", "XXXX ", "X    ", "X    "],
            'Q': [" XXX ", "X   X", "X X X", "X  X ", " XX X"],
            'R': ["XXXX ", "X   X", "XXXX ", "X  X ", "X   X"],
            'S': [" XXXX", "X    ", " XXX ", "    X", "XXXX "],
            'T': ["XXXXX", "  X  ", "  X  ", "  X  ", "  X  "],
            'U': ["X   X", "X   X", "X   X", "X   X", " XXX "],
            'V': ["X   X", "X   X", "X   X", " X X ", "  X  "],
            'W': ["X   X", "X   X", "X X X", "XX XX", "X   X"],
            'X': ["X   X", " X X ", "  X  ", " X X ", "X   X"],
            'Y': ["X   X", " X X ", "  X  ", "  X  ", "  X  "],
            'Z': ["XXXXX", "   X ", "  X  ", " X   ", "XXXXX"],
            '0': [" XXX ", "X   X", "X   X", "X   X", " XXX "],
            '1': ["  X  ", " XX  ", "  X  ", "  X  ", " XXX "],
            '2': [" XXX ", "X   X", "   X ", "  X  ", "XXXXX"],
            '3': [" XXX ", "X   X", "  XX ", "X   X", " XXX "],
            '4': ["   X ", "  XX ", " X X ", "XXXXX", "   X "],
            '5': ["XXXXX", "X    ", "XXXX ", "    X", "XXXX "],
            '6': [" XXXX", "X    ", "XXXX ", "X   X", " XXXX"],
            '7': ["XXXXX", "    X", "   X ", "  X  ", "  X  "],
            '8': [" XXX ", "X   X", " XXX ", "X   X", " XXX "],
            '9': [" XXXX", "X   X", " XXXX", "    X", " XXXX"],
            '!': ["  X  ", "  X  ", "  X  ", "     ", "  X  "],
            '?': [" XXX ", "X   X", "   X ", "     ", "  X  "],
            '.': ["     ", "     ", "     ", "     ", "  X  "]
        }

        if char in font:
            for row_idx, row in enumerate(font[char]):
                for col_idx, pixel in enumerate(row):
                    if pixel == 'X' and start_x + col_idx < 64 and start_y + row_idx < 64:
                        self.canvas.create_rectangle(
                            (start_x + col_idx) * self.square_size, (start_y + row_idx) * self.square_size,
                            (start_x + col_idx + 1) * self.square_size, (start_y + row_idx + 1) * self.square_size,
                            fill=self.current_color, outline="")
                        # Actualizar la matriz de colores
                        self.update_grid(start_x + col_idx, start_y + row_idx)

    def save_image(self):
        # Guardar la imagen en un archivo en formato C
        file_path = filedialog.asksaveasfilename(defaultextension=".c",
                                                 filetypes=[("C files", "*.h"),
                                                            ("All files", "*.*")])
        if file_path:
            with open(file_path, 'w') as f:
                f.write("volatile uint8_t test[32][64] = {\n")
                for row in range(32):
                    f.write("    {")
                    for col in range(64):
                        # Desplazar 3 bits a la izquierda el valor de la fila inferior
                        shifted_value = (self.grid[row + 32][col] & 0x07) << 3
                        # Combinar el valor desplazado con el valor de la fila superior
                        combined_value = shifted_value | (self.grid[row][col] & 0x07)
                        f.write(f"0x{combined_value:02x}, ")
                    f.write("},\n")
                f.write("};\n")

if __name__ == "__main__":
    root = tk.Tk()
    app = DrawingApp(root)
    root.mainloop()
