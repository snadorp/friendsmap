class GoogleEarth
  init: (me, friends) ->
    @me = jQuery.parseJSON me
    @friends = jQuery.parseJSON friends
    window.google.load('earth', '1', {"callback" : @callback})
    
  callback: =>
    window.google.earth.createInstance('map3d', @initCB, @failureCB)
    
  failureCB: (errorCode) =>
    console.log 'failureCB: Something went wrong :-/'

  initCB: (inst) =>
    inst.getNavigationControl().setVisibility(inst.VISIBILITY_AUTO)
    for friend in @friends
      placemark = inst.createPlacemark(friend.name)
      placemark.setName("") #We could set the friends name in here but that will mess the view up.
      placemark.setDescription(friend.name + "<br>Lives in "+friend.place+"<br>Distance: " + friend.distance + " km")
      icon = inst.createIcon('')
      icon.setHref(friend.picture)
      style = inst.createStyle('')
      style.getIconStyle().setIcon(icon)
      style.getIconStyle().setScale(1.0)
      placemark.setStyleSelector(style)
      #placemark location
      point = inst.createPoint('')
      point.setLatitude friend.latitude
      point.setLongitude friend.longitude
      placemark.setGeometry(point)
      #Add placemark to GoogleEarth
      inst.getFeatures().appendChild(placemark)

      #Connection line stuff
      lineStringPlacemark = inst.createPlacemark('')
      lineString = inst.createLineString('')
      lineStringPlacemark.setGeometry(lineString)
      lineString.setAltitudeMode(inst.ALTITUDE_CLAMP_TO_GROUND)
      lineString.setTessellate true
      lineString.getCoordinates().pushLatLngAlt(@me.latitude, @me.longitude, 0)
      lineString.getCoordinates().pushLatLngAlt(friend.latitude, friend.longitude, 0)
      lineStringPlacemark.setStyleSelector(inst.createStyle(''))
      lineStyle = lineStringPlacemark.getStyleSelector().getLineStyle()
      lineStyle.setWidth(2.5)
      lineStyle.getColor().set('4178D2F0')  # aabbggrr format

      #Add connection line to GoogleEarth
      inst.getFeatures().appendChild(lineStringPlacemark)
    inst.getWindow().setVisibility true

    #Camera stuff
    lookAt = inst.getView().copyAsLookAt(inst.ALTITUDE_RELATIVE_TO_GROUND)
    #Set the user home location as startingpoint
    lookAt.setLatitude @me.latitude
    lookAt.setLongitude @me.longitude
    lookAt.setRange(lookAt.getRange() / 4.5)
    #Update the view in Google Earth
    inst.getView().setAbstractView(lookAt)
     
@.ge = new GoogleEarth()