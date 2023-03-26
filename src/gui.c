//File: gui.c
//Author: Juhana Kammonen 26 Mar 2023
//Purpose: source code for btctick GUI

#include <gtk/gtk.h>

static void activate (GtkApplication* gui, gpointer user_data)
{
  GtkWidget *window;

  window = gtk_application_window_new (gui);
  gtk_window_set_title (GTK_WINDOW (window), "btctick");
  gtk_window_set_default_size (GTK_WINDOW (window), 300, 300);
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
