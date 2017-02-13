//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【設定】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

inline int MinI( float A_, float B_, float C_ )
{
    if ( A_ <= B_ )
    {
        if ( A_ <= C_ ) return 0;
                   else return 2;
    }
    else
    {
        if ( B_ <= C_ ) return 1;
                   else return 2;
    }
}

//##############################################################################

struct TSenderP
{
    float4 Scr :SV_Position;
    float4 Pos :TEXCOORD0  ;
};

struct TResultP
{
    float4 Col :SV_Target;
};

////////////////////////////////////////////////////////////////////////////////

TResultP MainP( TSenderP _Sender )
{
    TResultP _Result;

    float4 E = mul( _EyePos, _MatrixGL );
    float3 V = normalize( _Sender.Pos.xyz - E.xyz );

    int3 _VoxelsN;
    _Texture3D.GetDimensions( _VoxelsN.x,
                              _VoxelsN.y,
                              _VoxelsN.z );

    int3 Id;
    Id.x = sign( V.x );
    Id.y = sign( V.y );
    Id.z = sign( V.z );

    int3 Iv[ 3 ] = { { Id.x,    0,    0 },
                     {    0, Id.y,    0 },
                     {    0,    0, Id.z } };

    float3 Sd = _Size / _VoxelsN;

    float3 Td;
    Td.x = Sd.x / abs( V.x );
    Td.y = Sd.y / abs( V.y );
    Td.z = Sd.z / abs( V.z );

    float3 Tv[ 3 ] = { { Td.x,    0,    0 },
                       {    0, Td.y,    0 },
                       {    0,    0, Td.z } };

    float3 P = _Sender.Pos.xyz / Sd;

    int3 I;
    I.x = floor( P.x );
    I.y = floor( P.y );
    I.z = floor( P.z );

    float3 Pd = P - I;

    float3 T;
    if ( V.x > 0 ) T.x = Td.x * ( 1 - Pd.x ); else T.x = Td.x * Pd.x;
    if ( V.y > 0 ) T.y = Td.y * ( 1 - Pd.y ); else T.y = Td.y * Pd.y;
    if ( V.z > 0 ) T.z = Td.z * ( 1 - Pd.z ); else T.z = Td.z * Pd.z;

    _Result.Col = 0;

    int K;

    float T0 = 0;
    float T1;

    [loop]
    while ( ( -1 <= I.x ) && ( I.x <= _VoxelsN.x )
         && ( -1 <= I.y ) && ( I.y <= _VoxelsN.y )
         && ( -1 <= I.z ) && ( I.z <= _VoxelsN.z ) )
    {
        K = MinI( T.x, T.y, T.z );

        T1 = T[ K ];

        _Result.Col += ( T1 - T0 ) * _Texture3D.Load( int4( I, 0 ) );

        T0 = T1;

        I = I + Iv[ K ];
        T = T + Tv[ K ];
    }

    _Result.Col /= 6;

    //--------------------------------------------------------------------------

    _Result.Col.a = 0;

    _Result.Col = _Opacity * _Result.Col;

    return _Result;
}

//##############################################################################
