from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes
import asyncpraw
import random

# Настройка Reddit API
reddit = asyncpraw.Reddit(
    client_id="Mb9msKApOERYc2C25_6WXw",        # Замените на ваш client_id
    client_secret="V4uTnIg4GqVXLMYsaWYlvTQcrhhHCw",  # Замените на ваш client_secret
    user_agent="meme1"         # Замените на ваш user_agent
)

# Функция для получения случайного мема из Reddit
async def get_meme_from_reddit(subreddit_name="memes"):
    try:
        subreddit = await reddit.subreddit(subreddit_name)
        posts = [post async for post in subreddit.hot(limit=50)]  # Получаем 50 горячих постов
        post = random.choice(posts)  # Выбираем случайный пост
        return post.url  # Возвращаем URL изображения
    except Exception as e:
        print(f"Ошибка при запросе к Reddit API: {e}")
        return None

# Обработчик команды /meme
async def meme(update: Update, context: ContextTypes.DEFAULT_TYPE):
    # Получаем аргументы команды (категорию мема)
    category = context.args[0] if context.args else "memes"
    
    # Получаем URL мема
    meme_url = await get_meme_from_reddit(category)
    
    if meme_url:
        # Отправляем мем пользователю
        await update.message.reply_photo(photo=meme_url)
    else:
        # Если не удалось получить мем, отправляем сообщение об ошибке
        await update.message.reply_text("Не удалось получить мем. Попробуйте позже.")

# Обработчик команды /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "Привет! Я бот, который присылает случайные мемы. "
        "Используй команду /meme, чтобы получить мем. "
        "Ты также можешь указать категорию, например: /meme programming"
    )

# Основная функция для запуска бота
def main():
    # Замените 'YOUR_TOKEN' на токен вашего бота
    TOKEN = "7185988565:AAEB2VdwCaVuLhGMfSYrAInKqohY8NffQzw"
    
    try:
        # Создаем объект Application и передаем ему токен бота
        application = ApplicationBuilder().token(TOKEN).build()

        # Регистрируем обработчики команд
        application.add_handler(CommandHandler("start", start))
        application.add_handler(CommandHandler("meme", meme))

        # Запускаем бота
        application.run_polling()
    except Exception as e:
        print(f"Произошла ошибка: {e}")

if __name__ == '__main__':
    main()