var StatusTimer = {
  refresh_timer: 60,
  current_timer: 0,

  /* Initialize status timer */
  init: function() {
    this.element = $("#refresh_timer");
    this.start();
  },

  /* Start timer execution */
  start: function() {
    this.current_timer = this.refresh_timer;
    this.refresh();
  },

  /* Refresh timer count and view */
  refresh: function() {
    if (this.current_timer <= 0) {
      window.location.reload();
      return;
    }

    this.current_timer--;
    this.element.text(this.current_timer);

    setTimeout(function() { 
      StatusTimer.refresh(); 
    }, 1000);
  }
};