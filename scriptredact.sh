#!/bin/bash
filename=$(zenity --file-selection --title="Выберите файл для редактирования")
if [[ ! -f "$filename" ]]; then
	zenity --error --title="Ошибка" --text="Файл не существует"
	exit 1
fi
file_content=$(cat "$filename")
mapfile -t lines_array < <(sed = <<< "$file_content" | sed 'N;s/\n/ /')
selected_line=""
while [[ -z "$selected_line" ]]; do
	selected_line=$(zenity --list --title="Выбор строки" --text="Выберите строку для редактирования:" --column="Строка" "${lines_array[@]}")
	if [[ -z "$selected_line" ]]; then
		if ! zenity --question --title="Предупреждение" --text="Вы не выбрали строку. Хотите выбрать строку снова?" --ok-label="Да" --cancel-label="Нет"; then
			zenity --info --title="Информация" --text="Редактирование отменено"
			exit 0
		fi
	fi
done
line_number=$(sed 's/^\([0-9]*\).*/\1/' <<< "$selected_line")
original_text=$(sed 's/^[0-9]* //' <<< "$selected_line")
edited_line=$(zenity --entry --title="Редактирование строки" --text="Введите новый текст для выбранной строки:" --entry-text="$original_text")
sed -i "${line_number}s/.*/$edited_line/" "$filename"
if zenity --question --title="Успех" --text="Файл успешно обработан. Хотите вывести содержимое файла?" --ok-label="Да" --cancel-label="Нет"; then
    zenity --text-info --title="Содержимое файла" --filename="$filename"
fi
