import cv2
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

def find_dominant_colors(image_path, k=3):
    # Загрузка изображения с использованием OpenCV
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    # Изменение размера изображения для ускорения вычислений
    image = image.reshape((image.shape[0] * image.shape[1], 3))
    
    # Применение алгоритма KMeans для нахождения основных цветов
    kmeans = KMeans(n_clusters=k)
    kmeans.fit(image)
    
    # Получение центров кластеров, которые представляют основные цвета
    colors = kmeans.cluster_centers_.astype(int)
    
    # Отображение основных цветов
    plt.figure(figsize=(6, 2))
    for i in range(len(colors)):
        color_patch = np.zeros((100, 100, 3), dtype=np.uint8)
        color_patch[:, :] = colors[i]
        plt.subplot(1, len(colors), i + 1)
        plt.imshow(color_patch)
        plt.axis('off')
    
    plt.show()

# Путь к вашему изображению
image_path = '/Users/dariapoliakova/Downloads/1701787917288k0lcj9xs.png'  # Укажите путь к вашему изображению

# Вызов функции для нахождения основных цветов на изображении
find_dominant_colors(image_path)
