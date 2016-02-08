jThree( function( j3 ) {

	$( "#loading" ).remove();

	j3.Orbit();
	j3.MMD.play();
	j3.MMD.edgeScale = 0;


	function rotateEarth() {
		j3("#earth").animate({ rotateY: "+=3.14" }, 50000, rotateEarth);
	}
	rotateEarth();





},
function() {
	alert( "This browser does not support WebGL." );
} );
