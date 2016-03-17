jThree( function( j3 ) {

	$( "#loading" ).remove();

	var orbit = j3.Orbit();
	j3.MMD.play( true );
	j3.MMD.edgeScale = 0;
    var stereo = j3.Stereo().stop();
    var vr = j3.MobileVR().stop();
    
    function resize() {
        if ( window.innerWidth > window.innerHeight ) {
            stereo.start();
            vr.start();
            orbit.enabled = false;
        } else {
            stereo.stop();
            vr.stop();
            orbit.enabled = true;
        }
    }
    resize();
    
    j3( "rdr" ).resize( resize );

	function rotateEarth() {
		j3("#earth").animate({ rotateY: "+=3.14" }, 50000, rotateEarth);
	}
	rotateEarth();

    j3( "#title" ).three( 0 ).renderDepth = -1;



},
function() {
	alert( "This browser does not support WebGL." );
} );