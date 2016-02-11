jThree( function( j3 ) {

	$( "#loading" ).remove();

	j3.Orbit();
	j3.MMD.play( true );
	j3.MMD.edgeScale = 0;
    var stereo = j3.Stereo().stop();
    
    function resize() {
       stereo[ window.innerWidth > window.innerHeight ? "start" : "stop" ]();
    }
    resize();
    
    j3( "rdr" ).resize( resize );

	function rotateEarth() {
		j3("#earth").animate({ rotateY: "+=3.14" }, 50000, rotateEarth);
	}
	rotateEarth();





},
function() {
	alert( "This browser does not support WebGL." );
} );
