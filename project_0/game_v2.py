from itertools import count
import numpy as np

def random_predict(number:int=1) ->int:
    """рандомно угадываем число

    Args:
        number (int, optional): Загаданное число. Defaults to 1.

    Returns:
        int: число попыток
    """
    count = 0
    while True:
        count+=1
        predict_number = np.random.randint(1, 101)
        if number == predict_number:
            break
    return(count)
print(f"Количество попыток: {random_predict()}")

def score_game(random_predict) -> int:
    """За какое число попыток в среднем из 1000 подходов наш алгоритм угадывает

    Args:
        random_predict (_type_): _description_

    Returns:
        int: _description_
    """
    count_ls = []
    np.random.seed(1)
    random_array = np.random.randint (1, 101, size=(1000))
    
    for number in random_array:
        count_ls.append(random_predict(number))
    score = int(np.mean(count_ls))
    
    print(f"Ваш алгоритм угадывает число в среднем за {score} попыток")
    return(score)
if __name__ == "__main__":
   score_game(random_predict)