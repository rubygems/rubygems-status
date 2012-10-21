var StatusTimer = new function() {
  this.element_id    = "refresh_timer";
  this.refresh_timer = 60;
  this.current_timer = 0;

  /* Start timer execution */
  this.start = function() {
    this.current_timer = this.refresh_timer;
    this.refresh();
  }

  /* Refresh timer count and view */
  this.refresh = function() {
    if (this.current_timer <= 0) {
      window.location.reload();
      return;
    }

    this.current_timer--;
    $("#" + this.element_id).text(this.current_timer);

    setTimeout(function() { 
      StatusTimer.refresh(); 
    }, 1000);
  }
};