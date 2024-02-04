from PIL import Image
import tkinter as tk
from tkinter import filedialog
import pyperclip as pyp
import matplotlib.pyplot as plt
import numpy as np


def convert_to_binary(image_path):
    # Open the image and convert to grayscale
    img = Image.open(image_path).convert("L")

    # Resize the image to 64x64 pixels
    img = img.resize((64, 64), Image.LANCZOS)

    # Convert the image to a binary sequence (invert logic)
    binary_sequence = "".join(
        "0" if pixel >= 128 else "1" for pixel in img.getdata())

    binary_sequence_draw = "".join(
        "1" if pixel >= 128 else "0" for pixel in img.getdata())

    return binary_sequence, binary_sequence_draw


def convert_to_coe(image_path, output_coe_path):
    binary_sequence, _ = convert_to_binary(image_path)

    # Write the binary sequence to a COE file
    with open(output_coe_path, 'w') as coe_file:
        coe_file.write("memory_initialization_radix=2;\n")
        coe_file.write("memory_initialization_vector=\n")

        # Write the binary sequence in 64-bit chunks
        for i in range(0, len(binary_sequence), 64):
            chunk = binary_sequence[i:i + 64]
            coe_file.write("  {}{},\n".format(
                "".join(chunk), "" if i + 64 >= len(binary_sequence) else " "))

    print("COE file generated successfully.")


def open_file():
    file_path = filedialog.askopenfilename(
        filetypes=[("Image files", "*.png;*.jpg;*.jpeg")])
    if file_path:
        binary_sequence, binary_sequence_draw = convert_to_binary(file_path)
        result_text.delete(1.0, tk.END)  # Clear previous result
        result_text.insert(tk.END, binary_sequence)

        # Visualize the binary sequence as an image
        visualize_binary(binary_sequence_draw)

        # Generate COE file
        output_coe_path = "output1.coe"
        convert_to_coe(file_path, output_coe_path)


def copy_to_clipboard():
    result = result_text.get(1.0, tk.END)
    pyp.copy(result)


def visualize_binary(binary_sequence):
    # Convert binary sequence to a 64x64 numpy array
    binary_array = np.array(list(map(int, binary_sequence)), dtype=np.uint8)
    binary_array = binary_array.reshape((64, 64))

    # Display the binary array using matplotlib
    plt.imshow(binary_array, cmap='grey', interpolation='nearest')
    plt.title("Binary Image")
    plt.show()


# Create the main window
root = tk.Tk()
root.title("Image to Binary Converter")

# Create and place widgets
open_button = tk.Button(root, text="Open Image", command=open_file)
open_button.pack(pady=10)

result_text = tk.Text(root, height=40, width=64)
result_text.pack(pady=10, padx=20)

copy_button = tk.Button(root, text="Copy to Clipboard",
                        command=copy_to_clipboard)
copy_button.pack(pady=10)

# Run the GUI
root.mainloop()
