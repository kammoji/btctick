
//	File:	gui.c
//	Author:	Juhana Kammonen 3 May 2023
//	Purpose: source code for btctick GUI
//	Use: 	Run main btctick script (btctick.sh) with the -g (--gui) option. This code is then compiled in runtime.
//	Compile:	The code uses gtk. Must be specified explicitly to compiler,
//			e.g. Ubuntu Linux:gcc -o gui gui.c `pkg-config --cflags --libs gtk4` 

#include <gtk/gtk.h>

static void activate (GtkApplication* gui, gpointer user_data)
{
  GtkWidget *window,*frame;

  window = gtk_application_window_new (gui);
  gtk_window_set_title (GTK_WINDOW (window), "btctick");
  gtk_window_set_default_size (GTK_WINDOW (window), 300, 300);

  frame = gtk_frame_new("Hello!");

  gtk_widget_show (window);
}

int main (int argc, char **argv)
{
  GtkApplication *gui;
  int status;

  gui = gtk_application_new ("org.gtk.example", G_APPLICATION_FLAGS_NONE);
  g_signal_connect (gui, "activate", G_CALLBACK (activate), NULL);
  status = g_application_run (G_APPLICATION (gui), argc, argv);
  g_object_unref (gui);

  return status;
}
