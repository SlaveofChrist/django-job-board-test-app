# Stage 1: Build CSS
FROM node:18-alpine AS css-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci || npm install
# Copier tout le projet pour que Tailwind puisse analyser les fichiers HTML
COPY . .
RUN npm run build:css

# Stage 2: Python App
FROM python:3.11
WORKDIR /app

RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install -r requirements.txt 

COPY . . 
# Copier le CSS généré depuis le premier stage
COPY --from=css-builder /app/static/dist/output.css ./static/dist/output.css

# Rendre le script exécutable et corriger les fins de ligne Windows si nécessaire
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

# Rassembler les fichiers statiques (ils iront dans le dossier 'staticfiles')
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["./entrypoint.sh"]