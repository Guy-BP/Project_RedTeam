FROM python

WORKDIR /app

COPY . .

RUN pip3 install -r requirements.txt

ENTRYPOINT ["pytest", "test.py"]
