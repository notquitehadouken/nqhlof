import tkinter as tk
from tkinter import ttk
from datetime import datetime
import sounderpy as spy
import threading

def fetch_and_plot():
    global data_source, model, dataset
    global station_entry, fcst_hour_entry, lat_entry, lon_entry
    global year_entry, month_entry, day_entry, hour_entry, result_label

    try:
        source = data_source.get()
        selected_model = model.get()
        selected_dataset = dataset.get() if source == "Reanalysis" else None
        station = station_entry.get().strip()
        fcst_hour = None
        lat = float(lat_entry.get()) if lat_entry.get() else None
        lon = float(lon_entry.get()) if lon_entry.get() else None
        year = int(year_entry.get())
        month = int(month_entry.get())
        day = int(day_entry.get())
        hour = int(hour_entry.get())

        timestamp = f"{year}{month:02}{day:02}_{hour:02}Z"
        filename = f"{source.lower()}_{selected_model}_{timestamp}.png"

        storm_motion = 'left_moving' if lat and lat < 0 else 'right_moving'

        print(f"Fetching data from {source} source...")

        if source == "Reanalysis":
            data = spy.get_model_data(
                model=selected_model,
                latlon=[lat, lon],
                year=year,
                month=f"{month:02d}",
                day=f"{day:02d}",
                hour=f"{hour:02d}",
                dataset=selected_dataset,
                box_avg_size=0.1,
                hush=True,
                clean_it=True
            )
        elif source == "BUFKIT":
            fcst_hour_str = fcst_hour_entry.get()
            if not fcst_hour_str.isdigit():
                raise ValueError("Forecast Hour must be an integer for BUFKIT.")
            fcst_hour = int(fcst_hour_str)
            if not station:
                raise ValueError("Station ID required for BUFKIT data.")
            print("Calling get_bufkit_data with parameters:")
            print(f"Model: {selected_model}, Station: {station}, Forecast Hour: {fcst_hour}")
            print(f"Run time: {year}-{month}-{day} {hour}Z")
            print(f"Model type: {type(selected_model)}, Station type: {type(station)}, fcst_hour type: {type(fcst_hour)}")
            data = spy.get_bufkit_data(
            model=selected_model,
            station=station,
            fcst_hour=fcst_hour,
            run_year=str(year),
            run_month=f"{month:02d}",
            run_day=f"{day:02d}",
            run_hour=f"{hour:02d}",
            hush=True,
            clean_it=True
        )

        elif source == "Observed":
            if not station:
                raise ValueError("Station ID required for Observed data.")
            data = spy.get_obs_data(
                station=station,
                year=year,
                month=f"{month:02d}",
                day=f"{day:02d}",
                hour=f"{hour:02d}",
                hush=True,
                clean_it=True
            )
        else:
            raise ValueError("Invalid data source selected.")

        print("Building and saving sounding plot...")
        spy.build_sounding(
            clean_data=data,
            color_blind=False,
            dark_mode=True,
            storm_motion=storm_motion,
            show_radar=False,
            save=True,
            filename=filename
        )

        print("Saving to CM1 format...")
        spy.to_file(
            file_type="cm1",
            clean_data=data,
            filename="input_sounding",
            convert_to_AGL=True
        )

        result_label.config(text=f"Saved:\n{filename}\ninput_sounding", foreground="lightgreen")

    except Exception as e:
        result_label.config(text=f"Error:\n{str(e)}", foreground="red")

def create_gui():
    global data_source, model, dataset
    global station_entry, fcst_hour_entry, lat_entry, lon_entry
    global year_entry, month_entry, day_entry, hour_entry, result_label

    root = tk.Tk()
    root.title("SounderPy Sonde Retriever")
    root.geometry("600x600")
    root.configure(bg="#2e2e2e")

    style = ttk.Style()
    style.theme_use("default")
    style.configure("TLabel", background="#2e2e2e", foreground="white", font=('Segoe UI', 10))
    style.configure("TButton", background="#444", foreground="white")
    style.configure("TEntry", fieldbackground="#444", foreground="white")

    def add_labeled_entry(text, row):
        ttk.Label(root, text=text).grid(row=row, column=0, sticky='w', padx=10, pady=3)
        entry = ttk.Entry(root)
        entry.grid(row=row, column=1, padx=10, pady=3)
        return entry

    def on_data_source_change(event=None):
        source = data_source.get()
        if source == "Reanalysis":
            model_menu.config(values=["rap-ruc", "era5", "ncep", "rap-now"])
            model_menu.current(0)
            lat_entry.config(state='normal')
            lon_entry.config(state='normal')
            station_entry.config(state='disabled')
            fcst_hour_entry.config(state='disabled')
            dataset_menu.config(state='normal')
        elif source == "BUFKIT":
            model_menu.config(values=["hrrr", "rap", "nam", "namnest", "gfs", "sref", "hiresw"])
            model_menu.current(0)
            lat_entry.config(state='disabled')
            lon_entry.config(state='disabled')
            station_entry.config(state='normal')
            fcst_hour_entry.config(state='normal')
            dataset_menu.config(state='disabled')
        elif source == "Observed":
            model_menu.config(values=[])
            model_menu.set('')
            lat_entry.config(state='disabled')
            lon_entry.config(state='disabled')
            station_entry.config(state='normal')
            fcst_hour_entry.config(state='disabled')
            dataset_menu.config(state='disabled')

    # GUI Widgets
    data_source = tk.StringVar(value="Reanalysis")
    ttk.Label(root, text="Data Source:").grid(row=0, column=0, sticky='w', padx=10, pady=3)
    source_menu = ttk.Combobox(root, textvariable=data_source, values=["Reanalysis", "BUFKIT", "Observed"])
    source_menu.grid(row=0, column=1, padx=10, pady=3)
    source_menu.bind("<<ComboboxSelected>>", on_data_source_change)

    model = tk.StringVar()
    dataset = tk.StringVar()

    ttk.Label(root, text="Model:").grid(row=1, column=0, sticky='w', padx=10, pady=3)
    model_menu = ttk.Combobox(root, textvariable=model, values=["rap-ruc", "era5", "ncep", "rap-now"])
    model_menu.grid(row=1, column=1, padx=10, pady=3)
    model_menu.current(0)

    ttk.Label(root, text="Dataset (optional):").grid(row=2, column=0, sticky='w', padx=10, pady=3)
    dataset_menu = ttk.Combobox(root, textvariable=dataset, values=[
        'None', "RAP_25km", "RAP_25km_old", "RAP_25km_anl", "RAP_25km_anl_old",
        "RAP_13km", "RAP_13km_old", "RAP_13km_anl", "RAP_13km_anl_old",
        "RUC_13km", "RUC_13km_old", "RUC_25km", "RUC_25km_old"
    ])
    dataset_menu.grid(row=2, column=1, padx=10, pady=3)

    station_entry = add_labeled_entry("Station ID (BUFKIT/Observed):", 3)
    fcst_hour_entry = add_labeled_entry("Forecast Hour (BUFKIT):", 4)
    lat_entry = add_labeled_entry("Latitude:", 5)
    lon_entry = add_labeled_entry("Longitude:", 6)
    year_entry = add_labeled_entry("Year:", 7)
    month_entry = add_labeled_entry("Month:", 8)
    day_entry = add_labeled_entry("Day:", 9)
    hour_entry = add_labeled_entry("Hour (UTC):", 10)

    fetch_button = ttk.Button(root, text="Fetch Sonde", command=lambda: threading.Thread(target=fetch_and_plot).start())
    fetch_button.grid(row=11, columnspan=2, pady=20)

    result_label = ttk.Label(root, text="", background="#2e2e2e", foreground="white", font=('Segoe UI', 9))
    result_label.grid(row=12, columnspan=2, padx=10, pady=10)

    on_data_source_change()
    root.mainloop()

if __name__ == "__main__":
    print("Starting GUI...")
    create_gui()
