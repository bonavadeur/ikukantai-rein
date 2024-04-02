FROM python:3.8-slim

ENV PYTHONUNBUFFERED True

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

RUN pip install gunicorn
RUN pip install -r requirements.txt

ENV FLASK_APP=app.py
# CMD ["flask", "run", "--host", "0.0.0.0"]

# CMD exec gunicorn --bind=127.0.0.1 --workers 1 --threads 8 --timeout 0 app:app:$PORT
CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers", "1", "--threads", "8", "app:app"]
